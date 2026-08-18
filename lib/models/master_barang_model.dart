class MasterBarangModel {
  final int plu;
  final String barcode;
  final String desc;
  final int c2;
  final int stack;
  final int tear;

  MasterBarangModel({
    required this.plu,
    required this.barcode,
    required this.desc,
    required this.c2,
    required this.stack,
    required this.tear,
  });

  factory MasterBarangModel.fromJson(Map<String, dynamic> json) {
    return MasterBarangModel(
      plu: json['plu'],
      barcode: json['barcode'],
      desc: json['desc'],
      c2: json['c2'],
      stack: json['stack'],
      tear: json['tear'],
    );
  }
}

