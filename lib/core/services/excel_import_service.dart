import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';

class ExcelImportService {
  static Future<int> importMasterBarang() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result == null || result.files.single.path == null) {
      return 0;
    }

    var bytes = File(result.files.single.path!).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    final db = await DatabaseHelper.instance.database;
    final batch = db.batch();
    int importedCount = 0;

    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      if (sheet == null) continue;

      // Lewati baris 0 (Header Column)
      for (int i = 1; i < sheet.maxRows; i++) {
        var row = sheet.rows[i];
        if (row.isEmpty || row[0]?.value == null) continue;

        int plu = int.tryParse(row[0]?.value.toString() ?? '0') ?? 0;
        String barcode = row[1]?.value?.toString() ?? '';
        String desc = row[2]?.value?.toString() ?? '';
        int c2 = int.tryParse(row[3]?.value.toString() ?? '0') ?? 0;
        int stack = int.tryParse(row[4]?.value.toString() ?? '0') ?? 0;
        int tear = int.tryParse(row[5]?.value.toString() ?? '0') ?? 0;

        if (plu > 0) {
          batch.insert(
            'master_barang',
            {
              'plu': plu,
              'barcode': barcode,
              'desc': desc,
              'c2': c2,
              'stack': stack,
              'tear': tear,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          importedCount++;
        }
      }
    }

    await batch.commit(noResult: true);
    return importedCount;
  }
}

