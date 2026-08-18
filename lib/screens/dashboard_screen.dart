import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../models/storage_location_model.dart';
import 'putaway_form_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedRak = 80;
  Map<String, int> _summary = {'total': 1863, 'terisi': 0, 'kosong': 1863};
  List<StorageLocationModel> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final summary = await DatabaseHelper.instance.getStorageSummary();
    final locs = await DatabaseHelper.instance.getLocationsByRak(_selectedRak);
    setState(() {
      _summary = summary;
      _locations = locs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('PETA STORAGE GUDANG', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange[900],
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Column(
        children: [
          // Ringkasan Total Slot Gudang
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1E1E1E),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryCard('TOTAL', _summary['total']!, Colors.blue),
                _buildSummaryCard('TERISI', _summary['terisi']!, Colors.redAccent),
                _buildSummaryCard('KOSONG', _summary['kosong']!, Colors.green),
              ],
            ),
          ),

          // Selector Tab Rak (Rak 80 - 96)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(17, (index) {
                int rakNum = (index <= 14) ? 80 + index : (index == 15 ? 95 : 96);
                bool isSelected = _selectedRak == rakNum;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: ChoiceChip(
                    label: Text('RAK $rakNum', style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold)),
                    selected: isSelected,
                    selectedColor: Colors.orange,
                    backgroundColor: const Color(0xFF2C2C2C),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedRak = rakNum);
                        _loadData();
                      }
                    },
                  ),
                );
              }),
            ),
          ),

          // Grid Peta Interactive Slot Lokasi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: _locations.length,
                    itemBuilder: (context, index) {
                      final item = _locations[index];
                      return InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PutawayFormScreen(initialLokasi: item.lokasi.toString()),
                            ),
                          );
                          if (result == true) _loadData();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: item.isOccupied ? Colors.red[900] : Colors.green[900],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: item.isOccupied ? Colors.red : Colors.green, width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.lokasi.toString(),
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Icon(
                                item.isOccupied ? Icons.inventory_2 : Icons.check_circle_outline,
                                color: Colors.white70,
                                size: 14,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange[800],
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PutawayFormScreen()),
          );
          if (result == true) _loadData();
        },
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text('INPUT / SCAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryCard(String label, int value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text('$value', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

