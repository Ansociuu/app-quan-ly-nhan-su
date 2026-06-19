import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee.dart';
import '../models/position.dart';

class AppData extends ChangeNotifier {
  List<Employee> _employees = [];
  List<Position> _positions = [];
  Map<String, String> _employeePosition = {}; // maNV -> maCV
  
  bool _isDarkMode = false;
  double _fontSizeMultiplier = 1.0;
  bool _isLoading = true;

  // Getters
  List<Employee> get employees => _employees;
  List<Position> get positions => _positions;
  Map<String, String> get employeePosition => _employeePosition;
  bool get isDarkMode => _isDarkMode;
  double get fontSizeMultiplier => _fontSizeMultiplier;
  bool get isLoading => _isLoading;

  AppData() {
    _initData();
  }

  // Khởi tạo và tải dữ liệu từ SharedPreferences
  Future<void> _initData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Tải cấu hình cài đặt
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _fontSizeMultiplier = prefs.getDouble('fontSizeMultiplier') ?? 1.0;

      // 2. Tải danh sách chức vụ
      final String? positionsJson = prefs.getString('positions');
      if (positionsJson != null) {
        final List<dynamic> decoded = json.decode(positionsJson);
        _positions = decoded.map((item) => Position.fromJson(item)).toList();
      } else {
        // Dữ liệu chức vụ mẫu ban đầu
        _positions = [
          Position(maCV: 'CV01', tenCV: 'Trưởng phòng', moTa: 'Quản lý và điều hành các hoạt động của phòng ban'),
          Position(maCV: 'CV02', tenCV: 'Phó phòng', moTa: 'Hỗ trợ trưởng phòng và quản lý công việc chung'),
          Position(maCV: 'CV03', tenCV: 'Nhân viên', moTa: 'Thực hiện các công việc chuyên môn được giao'),
        ];
      }

      // 3. Tải danh sách nhân viên
      final String? employeesJson = prefs.getString('employees');
      if (employeesJson != null) {
        final List<dynamic> decoded = json.decode(employeesJson);
        _employees = decoded.map((item) => Employee.fromJson(item)).toList();
      } else {
        // Dữ liệu nhân viên mẫu ban đầu
        _employees = [
          Employee(
            maNV: 'NV01',
            hoTen: 'Nguyễn Văn A',
            namSinh: 2002,
            gioiTinh: 'Nam',
            trinhDo: 'Đại học',
            queQuan: 'Hà Nội',
            avatarColorValue: 0xFF5C6BC0, // Indigo
            avatarAssetPath: 'assets/avatars/avatar1.png',
          ),
          Employee(
            maNV: 'NV02',
            hoTen: 'Trần Thị B',
            namSinh: 2001,
            gioiTinh: 'Nữ',
            trinhDo: 'Đại học',
            queQuan: 'Hải Phòng',
            avatarColorValue: 0xFFEC407A, // Pink
            avatarAssetPath: 'assets/avatars/avatar2.png',
          ),
          Employee(
            maNV: 'NV03',
            hoTen: 'Phạm Minh C',
            namSinh: 1999,
            gioiTinh: 'Nam',
            trinhDo: 'Cao đẳng',
            queQuan: 'Đà Nẵng',
            avatarColorValue: 0xFF26A69A, // Teal
            avatarAssetPath: 'assets/avatars/avatar3.png',
          ),
        ];
      }

      // 4. Tải danh sách gán chức vụ
      final String? empPosJson = prefs.getString('employeePosition');
      if (empPosJson != null) {
        final Map<String, dynamic> decoded = json.decode(empPosJson);
        _employeePosition = decoded.map((key, value) => MapEntry(key, value.toString()));
      } else {
        // Gán mẫu ban đầu
        _employeePosition = {
          'NV01': 'CV01',
          'NV02': 'CV03',
        };
      }
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu SharedPreferences: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- HÀM LƯU DỮ LIỆU ---
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setDouble('fontSizeMultiplier', _fontSizeMultiplier);
  }

  Future<void> _saveEmployees() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_employees.map((e) => e.toJson()).toList());
    await prefs.setString('employees', encoded);
  }

  Future<void> _savePositions() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_positions.map((p) => p.toJson()).toList());
    await prefs.setString('positions', encoded);
  }

  Future<void> _saveEmployeePosition() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(_employeePosition);
    await prefs.setString('employeePosition', encoded);
  }

  // --- QUẢN LÝ CÀI ĐẶT ---
  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
    _saveSettings();
  }

  void setFontSizeMultiplier(double value) {
    _fontSizeMultiplier = value;
    notifyListeners();
    _saveSettings();
  }

  // --- QUẢN LÝ NHÂN VIÊN ---
  bool addEmployee(Employee emp) {
    // Kiểm tra trùng mã nhân viên
    if (_employees.any((e) => e.maNV.toLowerCase() == emp.maNV.toLowerCase())) {
      return false;
    }
    _employees.add(emp);
    notifyListeners();
    _saveEmployees();
    return true;
  }

  bool updateEmployee(Employee updatedEmp) {
    final index = _employees.indexWhere((e) => e.maNV == updatedEmp.maNV);
    if (index != -1) {
      _employees[index] = updatedEmp;
      notifyListeners();
      _saveEmployees();
      return true;
    }
    return false;
  }

  void deleteEmployee(String maNV) {
    _employees.removeWhere((e) => e.maNV == maNV);
    // Xóa liên kết gán chức vụ nếu có
    _employeePosition.remove(maNV);
    notifyListeners();
    _saveEmployees();
    _saveEmployeePosition();
  }

  // --- QUẢN LÝ CHỨC VỤ ---
  bool addPosition(Position pos) {
    // Kiểm tra trùng mã chức vụ
    if (_positions.any((p) => p.maCV.toLowerCase() == pos.maCV.toLowerCase())) {
      return false;
    }
    _positions.add(pos);
    notifyListeners();
    _savePositions();
    return true;
  }

  bool updatePosition(Position updatedPos) {
    final index = _positions.indexWhere((p) => p.maCV == updatedPos.maCV);
    if (index != -1) {
      _positions[index] = updatedPos;
      notifyListeners();
      _savePositions();
      return true;
    }
    return false;
  }

  void deletePosition(String maCV) {
    _positions.removeWhere((p) => p.maCV == maCV);
    // Hủy chức vụ của tất cả nhân viên đang giữ chức vụ này
    _employeePosition.removeWhere((key, value) => value == maCV);
    notifyListeners();
    _savePositions();
    _saveEmployeePosition();
  }

  // --- GÁN CHỨC VỤ ---
  void assignPosition(String maNV, String maCV) {
    _employeePosition[maNV] = maCV;
    notifyListeners();
    _saveEmployeePosition();
  }

  void unassignPosition(String maNV) {
    _employeePosition.remove(maNV);
    notifyListeners();
    _saveEmployeePosition();
  }

  // Lấy tên chức vụ từ mã nhân viên
  String getPositionNameOfEmployee(String maNV) {
    final maCV = _employeePosition[maNV];
    if (maCV == null) return 'Chưa gán chức vụ';
    final pos = _positions.firstWhere((p) => p.maCV == maCV, orElse: () => Position(maCV: '', tenCV: 'Không xác định', moTa: ''));
    return pos.tenCV.isNotEmpty ? pos.tenCV : 'Chưa gán chức vụ';
  }

  // Thống kê nhân viên theo chức vụ
  Map<String, int> getPositionStatistics() {
    Map<String, int> stats = {};
    // Khởi tạo tất cả các chức vụ với số lượng 0
    for (var pos in _positions) {
      stats[pos.tenCV] = 0;
    }
    stats['Chưa gán'] = 0;

    for (var emp in _employees) {
      final maCV = _employeePosition[emp.maNV];
      if (maCV == null) {
        stats['Chưa gán'] = (stats['Chưa gán'] ?? 0) + 1;
      } else {
        final pos = _positions.firstWhere((p) => p.maCV == maCV, orElse: () => Position(maCV: '', tenCV: '', moTa: ''));
        if (pos.tenCV.isNotEmpty) {
          stats[pos.tenCV] = (stats[pos.tenCV] ?? 0) + 1;
        } else {
          stats['Chưa gán'] = (stats['Chưa gán'] ?? 0) + 1;
        }
      }
    }

    // Xóa các chức vụ có giá trị bằng 0 để biểu đồ trông sạch hơn,
    // nhưng giữ lại nếu muốn hiển thị tất cả. Để vẽ biểu đồ tốt nhất, ta lọc các mục > 0
    stats.removeWhere((key, value) => value == 0);
    return stats;
  }
}

class AppDataProvider extends InheritedNotifier<AppData> {
  const AppDataProvider({
    super.key,
    required AppData appData,
    required super.child,
  }) : super(notifier: appData);

  static AppData of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppDataProvider>();
    assert(provider != null, 'Không tìm thấy AppDataProvider trong widget tree');
    return provider!.notifier!;
  }
}
