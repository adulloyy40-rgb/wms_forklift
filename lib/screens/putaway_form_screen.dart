import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/database/database_helper.dart';
import '../models/master_barang_model.dart';

class PutawayFormScreen extends StatefulWidget {
  final String? initialLokasi;
  const PutawayFormScreen({Key? key, this.initialLokasi}) : super(key: key);

  @override
  _PutawayFormScreenState createState() => _PutawayFormScreenState();
}

class _PutawayFormScreenState extends State<PutawayFormScreen> {
  final _lokasiCtrl = TextEditingController();
  final _pluCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _c2Ctrl = TextEditingController();
  final _stackCtrl = TextEditingController();
  final _tearCtrl = TextEditingController();
  final _expCtrl = TextEditingController();

  int _calculatedQty = 0;
  bool _isSearchingPlu = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLokasi != null) {
      _lokasiCtrl.text = widget.initialLokasi!;
    }
  }

  void _recalculateQty() {
    int stack = int.tryParse(_stackCtrl.text) ?? 0;
    int tear = int.tryParse(_tearCtrl.text) ?? 0;
    setState(() {
      _calculatedQty = stack * tear;
    });
  }

  Future<void> _lookupPlu(String val) async {
    int? plu = int.tryParse(val.trim());
    if (plu == null) return;

    setState(() => _isSearchingPlu = true);
    MasterBarangModel? item = await DatabaseHelper.instance.getMasterByPlu(plu);
    setState(() => _isSearchingPlu = false);

    if (item != null) {
      _barcodeCtrl.text = item.barcode;
      _descCtrl.text = item.desc;
      _c2Ctrl.text = item.c2.toString();
      _stackCtrl.text = item.stack.toString();
      _tearCtrl.text = item.tear.toString();
      _recalculateQty();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLU tidak ditemukan di Master Barang!')),
      );
    }
  }

  Future<void> _selectExpDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 180)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _expCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveData() async {
    int? lokasi = int.tryParse(_lokasiCtrl.text);
    int? plu = int.tryParse(_pluCtrl.text);

    if (lokasi == null || plu == null || _expCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi, PLU, dan Exp Date wajib diisi!')),
      );
      return;
    }

    bool success = await DatabaseHelper.instance.savePutaway(
      lokasi: lokasi,
      plu: plu,
      descp: _descCtrl.text,
      conv2: int.tryParse(_c2Ctrl.text) ?? 0,
      stack: int.tryParse(_stackCtrl.text) ?? 0,
      tearMaster: int.tryParse(_tearCtrl.text) ?? 0,
      expDate: _expCtrl.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: Colors.green, content: Text('Berhasil disimpan ke storage!')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('FORM PUTAWAY PALET'),
        backgroundColor: Colors.orange[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(_lokasiCtrl, 'KODE LOKASI (7 Digit)', Icons.location_on, isNumber: true),
            const SizedBox(height: 12),
            TextField(
              controller: _pluCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              onChanged: _lookupPlu,
              decoration: InputDecoration(
                labelText: 'PLU BARANG',
                labelStyle: const TextStyle(color: Colors.orange),
                prefixIcon: const Icon(Icons.qr_code, color: Colors.orange),
                suffixIcon: _isSearchingPlu
                    ? const CircularProgressIndicator(color: Colors.orange)
                    : IconButton(icon: const Icon(Icons.search, color: Colors.orange), onPressed: () => _lookupPlu(_pluCtrl.text)),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(_barcodeCtrl, 'BARCODE (Otomatis Master)', Icons.barcode_reader, readOnly: true),
            const SizedBox(height: 12),
            _buildTextField(_descCtrl, 'DESCRIPTION (Otomatis Master)', Icons.description, readOnly: true),
            const SizedBox(height: 12),
            _buildTextField(_c2Ctrl, 'CONV2 / C2 (Otomatis Master)', Icons.widgets, readOnly: true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stackCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (_) => _recalculateQty(),
                    decoration: InputDecoration(
                      labelText: 'STACK',
                      labelStyle: const TextStyle(color: Colors.orange),
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _tearCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (_) => _recalculateQty(),
                    decoration: InputDecoration(
                      labelText: 'TEAR MASTER',
                      labelStyle: const TextStyle(color: Colors.orange),
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.orange[900]?.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL QTY SO:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('$_calculatedQty CTN', style: const TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _expCtrl,
              readOnly: true,
              onTap: _selectExpDate,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'TANGGAL EXPIRED (YYYY-MM-DD)',
                labelStyle: const TextStyle(color: Colors.orange),
                prefixIcon: const Icon(Icons.calendar_today, color: Colors.orange),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                minimumSize: const Size.fromHeight(54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _saveData,
              child: const Text('SIMPAN KE STORAGE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool readOnly = false, bool isNumber = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: readOnly ? Colors.white70 : Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: readOnly ? Colors.white54 : Colors.orange),
        prefixIcon: Icon(icon, color: readOnly ? Colors.white38 : Colors.orange),
        filled: true,
        fillColor: readOnly ? const Color(0xFF222222) : const Color(0xFF2C2C2C),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

