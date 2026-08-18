import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';

class ExcelExportService {
  static Future<String?> exportSoStorage() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> records = await db.query(
      'so_storage',
      orderBy: 'lokasi ASC',
    );

    var excel = Excel.createExcel();
    Sheet sheetObject = excel['DATA_SO_STORAGE_NEW'];
    excel.setDefaultSheet('DATA_SO_STORAGE_NEW');

    // Buat Header Excel
    List<String> headers = [
      'LOKASI',
      'PLU',
      'DESCP',
      'CONV2',
      'QTY_SO',
      'STACK',
      'TEAR_MASTER',
      'EXP_DATE',
      'IS_OCCUPIED',
      'UPDATED_AT'
    ];
    sheetObject.appendRow(headers.map((e) => TextCellValue(e)).toList());

    // Masukkan Baris Data
    for (var row in records) {
      sheetObject.appendRow([
        IntCellValue(row['lokasi'] ?? 0),
        IntCellValue(row['plu'] ?? 0),
        TextCellValue(row['descp'] ?? ''),
        IntCellValue(row['conv2'] ?? 0),
        IntCellValue(row['qty_so'] ?? 0),
        IntCellValue(row['stack'] ?? 0),
        IntCellValue(row['tear_master'] ?? 0),
        TextCellValue(row['exp_date'] ?? ''),
        IntCellValue(row['is_occupied'] ?? 0),
        TextCellValue(row['updated_at'] ?? ''),
      ]);
    }

    // Simpan ke Penyimpanan Lokal & Bagikan File
    final directory = await getApplicationDocumentsDirectory();
    String fileName = 'DATA_SO_STORAGE_NEW_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    String filePath = '${directory.path}/$fileName';

    List<int>? fileBytes = excel.save();
    if (fileBytes != null) {
      File file = File(filePath);
      await file.writeAsBytes(fileBytes);
      await Share.shareXFiles([XFile(filePath)], text: 'Export Data Stock Opname Storage Gudang');
      return filePath;
    }
    return null;
  }
}

