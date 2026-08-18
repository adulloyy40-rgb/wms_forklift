class StorageLocationModel {
  final int lokasi;
  final int? plu;
  final String? descp;
  final int? conv2;
  final int? qtySo;
  final int? stack;
  final int? tearMaster;
  final String? expDate;
  final bool isOccupied;

  StorageLocationModel({
    required this.lokasi,
    this.plu,
    this.descp,
    this.conv2,
    this.qtySo,
    this.stack,
    this.tearMaster,
    this.expDate,
    required this.isOccupied,
  });

  factory StorageLocationModel.fromJson(Map<String, dynamic> json) {
    return StorageLocationModel(
      lokasi: json['lokasi'],
      plu: json['plu'],
      descp: json['descp'],
      conv2: json['conv2'],
      qtySo: json['qty_so'],
      stack: json['stack'],
      tearMaster: json['tear_master'],
      expDate: json['exp_date'],
      isOccupied: json['is_occupied'] == 1,
    );
  }
}

