class Position {
  final String maCV;
  final String tenCV;
  final String moTa;

  Position({
    required this.maCV,
    required this.tenCV,
    required this.moTa,
  });

  // Chuyển đổi đối tượng sang Map để lưu trữ JSON
  Map<String, dynamic> toJson() {
    return {
      'maCV': maCV,
      'tenCV': tenCV,
      'moTa': moTa,
    };
  }

  // Khởi tạo đối tượng từ Map (JSON)
  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      maCV: json['maCV'] ?? '',
      tenCV: json['tenCV'] ?? '',
      moTa: json['moTa'] ?? '',
    );
  }

  // Sao chép đối tượng với một số thuộc tính thay đổi
  Position copyWith({
    String? maCV,
    String? tenCV,
    String? moTa,
  }) {
    return Position(
      maCV: maCV ?? this.maCV,
      tenCV: tenCV ?? this.tenCV,
      moTa: moTa ?? this.moTa,
    );
  }
}
