import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/master_barang_model.dart';
import '../../models/storage_location_model.dart';

extension DatabaseHelperPutaway on DatabaseHelper {
  // Ambil Ringkasan Gudang (Total, Terisi, Kosong)
  Future<Map<String, int>> getStorageSummary() async {
    final db = await instance.database;
    final total = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM so_storage')) ?? 0;
    final terisi = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM so_storage WHERE is_occupied = 1')) ?? 0;
    return {
      'total': total,
      'terisi': terisi,
      'kosong': total - terisi,
    };
  }

  // Ambil Daftar Lokasi berdasarkan Nomor Rak (80 - 96)
  Future<List<StorageLocationModel>> getLocationsByRak(int rak) async {
    final db = await instance.database;
    String rakPrefix = rak.toString().padLeft(2, '0');
    final result = await db.rawQuery(
      'SELECT * FROM so_storage WHERE CAST(lokasi AS TEXT) LIKE ? ORDER BY lokasi ASC',
      ['$rakPrefix%'],
    );
    return result.map((json) => StorageLocationModel.fromJson(json)).toList();
  }

  // Cari Master Barang Berdasarkan PLU
  Future<MasterBarangModel?> getMasterByPlu(int plu) async {
    final db = await instance.database;
    final result = await db.query('master_barang', where: 'plu = ?', whereArgs: [plu]);
    if (result.isNotEmpty) {
      return MasterBarangModel.fromJson(result.first);
    }
    return null;
  }

  // Simpan Transaksi Putaway Operator
  Future<bool> savePutaway({
    required int lokasi,
    required int plu,
    required String descp,
    required int conv2,
    required int stack,
    required int tearMaster,
    required String expDate,
  }) async {
    final db = await instance.database;
    int qtySo = stack * tearMaster;
    
    int count = await db.update(
      'so_storage',
      {
        'plu': plu,
        'descp': descp,
        'conv2': conv2,
        'qty_so': qtySo,
        'stack': stack,
        'tear_master': tearMaster,
        'exp_date': expDate,
        'is_occupied': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'lokasi = ?',
      whereArgs: [lokasi],
    );
    return count > 0;
  }
}

