class Employee {
  final String maNV;
  final String hoTen;
  final int namSinh;
  final String gioiTinh;
  final String trinhDo;
  final String queQuan;
  final int avatarColorValue; // Giá trị màu ARGB để hiển thị avatar độc nhất

  Employee({
    required this.maNV,
    required this.hoTen,
    required this.namSinh,
    required this.gioiTinh,
    required this.trinhDo,
    required this.queQuan,
    required this.avatarColorValue,
  });

  // Chuyển đổi đối tượng sang Map để lưu trữ JSON
  Map<String, dynamic> toJson() {
    return {
      'maNV': maNV,
      'hoTen': hoTen,
      'namSinh': namSinh,
      'gioiTinh': gioiTinh,
      'trinhDo': trinhDo,
      'queQuan': queQuan,
      'avatarColorValue': avatarColorValue,
    };
  }

  // Khởi tạo đối tượng từ Map (JSON)
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      maNV: json['maNV'] ?? '',
      hoTen: json['hoTen'] ?? '',
      namSinh: json['namSinh'] is int ? json['namSinh'] : int.parse(json['namSinh'].toString()),
      gioiTinh: json['gioiTinh'] ?? '',
      trinhDo: json['trinhDo'] ?? '',
      queQuan: json['queQuan'] ?? '',
      avatarColorValue: json['avatarColorValue'] ?? 0xFF5C6BC0, // Mặc định là màu Indigo nhẹ
    );
  }

  // Sao chép đối tượng với một số thuộc tính thay đổi
  Employee copyWith({
    String? maNV,
    String? hoTen,
    int? namSinh,
    String? gioiTinh,
    String? trinhDo,
    String? queQuan,
    int? avatarColorValue,
  }) {
    return Employee(
      maNV: maNV ?? this.maNV,
      hoTen: hoTen ?? this.hoTen,
      namSinh: namSinh ?? this.namSinh,
      gioiTinh: gioiTinh ?? this.gioiTinh,
      trinhDo: trinhDo ?? this.trinhDo,
      queQuan: queQuan ?? this.queQuan,
      avatarColorValue: avatarColorValue ?? this.avatarColorValue,
    );
  }
}
