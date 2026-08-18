class OperatorModel {
  final String id;
  final String nama;
  final String shift; // 'Pagi' atau 'Malam'
  final String loginTime;

  OperatorModel({
    required this.id,
    required this.nama,
    required this.shift,
    required this.loginTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'shift': shift,
    'loginTime': loginTime,
  };
}

