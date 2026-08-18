import 'package:flutter/material.dart';
import '../services/excel_import_service.dart';
import '../services/excel_export_service.dart';

class ExcelManagerScreen extends StatefulWidget {
  const ExcelManagerScreen({Key? key}) : super(key: key);

  @override
  _ExcelManagerScreenState createState() => _ExcelManagerScreenState();
}

class _ExcelManagerScreenState extends State<ExcelManagerScreen> {
  bool _isProcessing = false;
  String _statusMessage = 'Siap melakukan proses data.';

  void _handleImport() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Membaca dan memasukkan file Excel ke database...';
    });

    try {
      int count = await ExcelImportService.importMasterBarang();
      setState(() {
        _statusMessage = count > 0 
            ? 'Berhasil mengimpor $count data Master Barang!' 
            : 'Proses impor dibatalkan atau file kosong.';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Gagal mengimpor: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _handleExport() async {
    setState(() {
      _isProcessing = true;
      _statusMessage = 'Menyusun berkas Excel laporan SO Storage...';
    });

    try {
      String? path = await ExcelExportService.exportSoStorage();
      setState(() {
        _statusMessage = path != null 
            ? 'Ekspor berhasil disimpan!' 
            : 'Proses ekspor dibatalkan.';
      });
    } catch (e) {
      setState(() => _statusMessage = 'Gagal mengekspor: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('INTEGRASI DATA EXCEL'),
        backgroundColor: Colors.orange[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAlignment.stretch,
          children: [
            const Icon(Icons.note_alt_outlined, size: 70, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),

            if (_isProcessing)
              const Center(child: CircularProgressIndicator(color: Colors.orange))
            else ...[
              // Tombol Impor
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2C),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.orange, width: 1.5),
                  ),
                ),
                icon: const Icon(Icons.file_upload, color: Colors.orange, size: 28),
                label: const Text(
                  'IMPORT MASTER_BARANG.XLSX',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _handleImport,
              ),
              const SizedBox(height: 20),

              // Tombol Ekspor
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.file_download, color: Colors.white, size: 28),
                label: const Text(
                  'EXPORT DATA_SO_STORAGE_NEW.XLSX',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _handleExport,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

