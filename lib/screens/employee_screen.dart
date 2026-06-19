import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/app_data.dart';
import '../models/employee.dart';
import '../widgets/employee_card.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  String _searchQuery = '';
  String _selectedGenderFilter = 'Tất cả';
  String _selectedHomeTownFilter = 'Tất cả';
  String _sortByAge = 'none'; // 'none', 'asc' (năm sinh tăng dần - tuổi giảm dần), 'desc'

  final List<String> _avatarAssetPaths = [
    'assets/avatars/avatar1.png',
    'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.png',
    'assets/avatars/avatar5.png',
    'assets/avatars/avatar6.png',
  ];

  final List<int> _avatarColors = [
    0xFF5C6BC0, // Indigo
    0xFFEC407A, // Pink
    0xFF26A69A, // Teal
    0xFF42A5F5, // Blue
    0xFFAB47BC, // Purple
    0xFFFFA726, // Orange
    0xFF78909C, // Blue Grey
    0xFF66BB6A, // Green
  ];

  @override
  Widget build(BuildContext context) {
    final appData = AppDataProvider.of(context);
    final theme = Theme.of(context);

    // Lấy danh sách quê quán động từ các nhân viên hiện tại để làm bộ lọc
    final Set<String> towns = appData.employees.map((e) => e.queQuan.trim()).where((t) => t.isNotEmpty).toSet();
    final List<String> homeTownList = ['Tất cả', ...towns];

    // Lọc và Sắp xếp danh sách nhân viên hiển thị
    List<Employee> displayedEmployees = appData.employees.where((emp) {
      // 1. Tìm kiếm (Mã NV, Tên, Quê quán)
      final query = _searchQuery.toLowerCase();
      final matchQuery = emp.maNV.toLowerCase().contains(query) ||
          emp.hoTen.toLowerCase().contains(query) ||
          emp.queQuan.toLowerCase().contains(query) ||
          emp.trinhDo.toLowerCase().contains(query);

      // 2. Lọc theo Giới tính
      final matchGender = _selectedGenderFilter == 'Tất cả' || emp.gioiTinh == _selectedGenderFilter;

      // 3. Lọc theo Quê quán
      final matchTown = _selectedHomeTownFilter == 'Tất cả' || emp.queQuan.trim() == _selectedHomeTownFilter;

      return matchQuery && matchGender && matchTown;
    }).toList();

    // 4. Sắp xếp theo Năm sinh
    if (_sortByAge == 'asc') {
      displayedEmployees.sort((a, b) => a.namSinh.compareTo(b.namSinh));
    } else if (_sortByAge == 'desc') {
      displayedEmployees.sort((a, b) => b.namSinh.compareTo(a.namSinh));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Nhân viên'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Xuất báo cáo PDF',
            onPressed: () => _exportToPdf(context, appData),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Khu vực Tìm kiếm và Bộ lọc
          _buildSearchAndFilterPanel(theme, homeTownList),

          // Danh sách Nhân viên
          Expanded(
            child: displayedEmployees.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80), // Cách FAB
                    itemCount: displayedEmployees.length,
                    itemBuilder: (context, index) {
                      final emp = displayedEmployees[index];
                      final positionName = appData.getPositionNameOfEmployee(emp.maNV);
                      return EmployeeCard(
                        employee: emp,
                        positionName: positionName,
                        onEdit: () => _showEmployeeFormDialog(context, emp),
                        onDelete: () => _showDeleteConfirmDialog(context, appData, emp),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEmployeeFormDialog(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Thêm nhân viên'),
      ),
    );
  }

  // --- WIDGETS GIAO DIỆN ---

  Widget _buildSearchAndFilterPanel(ThemeData theme, List<String> homeTownList) {
    final isDark = theme.brightness == Brightness.dark;
    
    // Đảm bảo phần quê quán đã chọn vẫn nằm trong list (phòng trường hợp nhân viên bị xóa mất quê quán đó)
    if (!homeTownList.contains(_selectedHomeTownFilter)) {
      _selectedHomeTownFilter = 'Tất cả';
    }

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          // Thanh tìm kiếm
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên, mã NV, quê quán...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.grey[100],
            ),
          ),
          const SizedBox(height: 8),
          
          // Thanh Bộ lọc & Sắp xếp
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Lọc Giới tính
                _buildFilterDropdown<String>(
                  label: 'Giới tính: $_selectedGenderFilter',
                  items: const ['Tất cả', 'Nam', 'Nữ', 'Khác'],
                  value: _selectedGenderFilter,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedGenderFilter = val;
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),

                // Lọc Quê Quán
                _buildFilterDropdown<String>(
                  label: 'Quê quán: $_selectedHomeTownFilter',
                  items: homeTownList,
                  value: _selectedHomeTownFilter,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedHomeTownFilter = val;
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),

                // Sắp xếp Năm sinh
                _buildFilterDropdown<String>(
                  label: _sortByAge == 'none'
                      ? 'Sắp xếp: Mặc định'
                      : _sortByAge == 'asc'
                          ? 'Năm sinh: Tăng dần ➔'
                          : 'Năm sinh: Giảm dần ➔',
                  items: const ['none', 'asc', 'desc'],
                  value: _sortByAge,
                  displayBuilder: (val) {
                    if (val == 'none') return 'Mặc định';
                    if (val == 'asc') return 'Năm sinh tăng dần';
                    return 'Năm sinh giảm dần';
                  },
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _sortByAge = val;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown<T>({
    required String label,
    required List<T> items,
    required T value,
    String Function(T)? displayBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.15)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.arrow_drop_down, size: 18),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          onChanged: onChanged,
          items: items.map((T item) {
            final displayText = displayBuilder != null ? displayBuilder(item) : item.toString();
            return DropdownMenuItem<T>(
              value: item,
              child: Text(displayText),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 72,
              color: theme.colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy nhân viên nào',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy thử thay đổi điều kiện tìm kiếm/bộ lọc hoặc nhấn nút bên dưới để thêm nhân viên mới.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOG THÊM / SỬA NHÂN VIÊN ---
  void _showEmployeeFormDialog(BuildContext context, Employee? existingEmployee) {
    final appData = AppDataProvider.of(context);
    final isEdit = existingEmployee != null;

    final formKey = GlobalKey<FormState>();
    final maNVController = TextEditingController(text: existingEmployee?.maNV ?? '');
    final hoTenController = TextEditingController(text: existingEmployee?.hoTen ?? '');
    final queQuanController = TextEditingController(text: existingEmployee?.queQuan ?? '');
    
    int selectedYear = existingEmployee?.namSinh ?? 2000;
    String selectedGender = existingEmployee?.gioiTinh ?? 'Nam';
    String selectedTrinhDo = existingEmployee?.trinhDo ?? 'Đại học';
    String selectedAvatarPath = existingEmployee?.avatarAssetPath ?? 'assets/avatars/avatar1.png';

    final List<String> trinhDoOptions = [
      'Trung cấp',
      'Cao đẳng',
      'Đại học',
      'Thạc sĩ',
      'Tiến sĩ',
      'Khác'
    ];
    if (!trinhDoOptions.contains(selectedTrinhDo)) {
      trinhDoOptions.add(selectedTrinhDo);
    }

    // Picker chọn năm sinh chuyên dụng bằng showDatePicker
    Future<void> selectYearOfBirth(BuildContext dialogContext, StateSetter setDialogState) async {
      final DateTime? picked = await showDatePicker(
        context: dialogContext,
        initialDate: DateTime(selectedYear, 1, 1),
        firstDate: DateTime(1950),
        lastDate: DateTime(DateTime.now().year - 15), // Tối thiểu 15 tuổi
        helpText: 'CHỌN NĂM SINH NHÂN VIÊN',
        initialDatePickerMode: DatePickerMode.year,
      );
      if (picked != null) {
        setDialogState(() {
          selectedYear = picked.year;
        });
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder( // Để quản lý trạng thái ngay trong Dialog
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(
                    isEdit ? Icons.edit_note : Icons.person_add_alt_1,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(isEdit ? 'Sửa Nhân Viên' : 'Thêm Nhân Viên Mới'),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mã NV (Chỉ cho nhập khi Thêm mới, Sửa thì khóa)
                        TextFormField(
                          controller: maNVController,
                          enabled: !isEdit,
                          decoration: InputDecoration(
                            labelText: 'Mã nhân viên',
                            hintText: 'Ví dụ: NV04',
                            prefixIcon: const Icon(Icons.tag),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Mã nhân viên không được để trống';
                            }
                            if (!isEdit && appData.employees.any((e) => e.maNV.toLowerCase() == value.trim().toLowerCase())) {
                              return 'Mã nhân viên đã tồn tại';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Họ tên nhân viên
                        TextFormField(
                          controller: hoTenController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: 'Họ và tên',
                            hintText: 'Nhập họ tên đầy đủ',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Họ tên không được để trống';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Chọn năm sinh bằng DatePicker
                        InkWell(
                          onTap: () => selectYearOfBirth(dialogContext, setDialogState),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Năm sinh: $selectedYear',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Thay đổi',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Giới tính (Segmented Button phong cách hiện đại)
                        Text(
                          'Giới tính',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: ['Nam', 'Nữ', 'Khác'].map((gender) {
                            final isSelected = selectedGender == gender;
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ChoiceChip(
                                  label: Text(gender),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) {
                                      setDialogState(() {
                                        selectedGender = gender;
                                      });
                                    }
                                  },
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Chọn hình đại diện (Avatar)
                        Text(
                          'Chọn ảnh đại diện',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 70,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _avatarAssetPaths.length,
                            itemBuilder: (context, index) {
                              final path = _avatarAssetPaths[index];
                              final isSelected = selectedAvatarPath == path;
                              return GestureDetector(
                                onTap: () {
                                  setDialogState(() {
                                    selectedAvatarPath = path;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.grey[200],
                                      child: ClipOval(
                                        child: Image.asset(
                                          path,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Trình độ học vấn (Dropdown)
                        DropdownButtonFormField<String>(
                          value: trinhDoOptions.contains(selectedTrinhDo) ? selectedTrinhDo : trinhDoOptions.first,
                          decoration: InputDecoration(
                            labelText: 'Trình độ học vấn',
                            prefixIcon: const Icon(Icons.school_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: trinhDoOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setDialogState(() {
                                selectedTrinhDo = newValue;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Quê quán
                        TextFormField(
                          controller: queQuanController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: 'Quê quán',
                            hintText: 'Nhập Tỉnh/Thành phố quê quán',
                            prefixIcon: const Icon(Icons.location_city),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Quê quán không được để trống';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final randomColorVal = _avatarColors[Random().nextInt(_avatarColors.length)];
                      
                      final emp = Employee(
                        maNV: maNVController.text.trim(),
                        hoTen: hoTenController.text.trim(),
                        namSinh: selectedYear,
                        gioiTinh: selectedGender,
                        trinhDo: selectedTrinhDo,
                        queQuan: queQuanController.text.trim(),
                        avatarColorValue: existingEmployee?.avatarColorValue ?? randomColorVal,
                        avatarAssetPath: selectedAvatarPath,
                      );

                      bool success;
                      if (isEdit) {
                        success = appData.updateEmployee(emp);
                      } else {
                        success = appData.addEmployee(emp);
                      }

                      if (success) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEdit
                                ? 'Cập nhật thông tin nhân viên thành công!'
                                : 'Thêm nhân viên mới thành công!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lỗi: Có lỗi xảy ra trong quá trình lưu trữ!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(isEdit ? 'Lưu thay đổi' : 'Thêm mới'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- DIALOG XÁC NHẬN XÓA NHÂN VIÊN ---
  void _showDeleteConfirmDialog(BuildContext context, AppData appData, Employee emp) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Xác nhận xóa'),
            ],
          ),
          content: Text.rich(
            TextSpan(
              text: 'Bạn có chắc chắn muốn xóa nhân viên ',
              children: [
                TextSpan(
                  text: emp.hoTen,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' (Mã: ${emp.maNV}) không? Mọi thông tin liên quan (bao gồm cả chức vụ đã gán) sẽ bị xóa hoàn toàn.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                appData.deleteEmployee(emp.maNV);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa nhân viên ${emp.hoTen}.'),
                    backgroundColor: Colors.blueGrey,
                  ),
                );
              },
              child: const Text('Xóa ngay'),
            ),
          ],
        );
      },
    );
  }

  // --- HÀM XUẤT DANH SÁCH NHÂN VIÊN RA PDF ---
  Future<void> _exportToPdf(BuildContext context, AppData appData) async {
    // Hiển thị vòng quay tải (loading) trong khi chuẩn bị font và file
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final pdf = pw.Document();

      // Tải font hỗ trợ Tiếng Việt (Roboto) từ Google Fonts qua thư viện printing
      final fontRegular = await PdfGoogleFonts.robotoRegular();
      final fontBold = await PdfGoogleFonts.robotoBold();

      final employees = appData.employees;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context pdfContext) {
            return [
              // Header báo cáo
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'ỨNG DỤNG QUẢN LÝ NHÂN SỰ',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'Mẫu báo cáo: BC-NV01',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 9,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Divider(thickness: 1, color: PdfColors.grey300),
                  pw.SizedBox(height: 16),
                  pw.Center(
                    child: pw.Text(
                      'BÁO CÁO DANH SÁCH NHÂN VIÊN',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 18,
                        color: PdfColors.indigo800,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Center(
                    child: pw.Text(
                      'Ngày lập báo cáo: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} | Tổng số: ${employees.length} nhân sự',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 10,
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColors.grey800,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                ],
              ),
              
              // Bảng dữ liệu nhân viên
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                columnWidths: {
                  0: const pw.FixedColumnWidth(25),  // STT
                  1: const pw.FixedColumnWidth(50),  // Mã NV
                  2: const pw.FixedColumnWidth(110), // Họ Tên
                  3: const pw.FixedColumnWidth(55),  // Năm sinh
                  4: const pw.FixedColumnWidth(50),  // Giới tính
                  5: const pw.FixedColumnWidth(70),  // Trình độ
                  6: const pw.FixedColumnWidth(75),  // Quê quán
                  7: const pw.FixedColumnWidth(85),  // Chức vụ
                },
                children: [
                  // Hàng tiêu đề của bảng
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _buildCell('STT', fontBold, isHeader: true),
                      _buildCell('Mã NV', fontBold, isHeader: true),
                      _buildCell('Họ Tên', fontBold, isHeader: true),
                      _buildCell('Năm sinh', fontBold, isHeader: true),
                      _buildCell('Giới tính', fontBold, isHeader: true),
                      _buildCell('Trình độ', fontBold, isHeader: true),
                      _buildCell('Quê quán', fontBold, isHeader: true),
                      _buildCell('Chức vụ', fontBold, isHeader: true),
                    ],
                  ),
                  // Các dòng dữ liệu nhân viên
                  for (int i = 0; i < employees.length; i++) ...[
                    pw.TableRow(
                      children: [
                        _buildCell('${i + 1}', fontRegular),
                        _buildCell(employees[i].maNV, fontRegular),
                        _buildCell(employees[i].hoTen, fontRegular, alignLeft: true),
                        _buildCell(employees[i].namSinh.toString(), fontRegular),
                        _buildCell(employees[i].gioiTinh, fontRegular),
                        _buildCell(employees[i].trinhDo, fontRegular),
                        _buildCell(employees[i].queQuan, fontRegular, alignLeft: true),
                        _buildCell(
                          appData.getPositionNameOfEmployee(employees[i].maNV),
                          fontRegular,
                          alignLeft: true,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              
              // Ký tên xác nhận
              pw.SizedBox(height: 35),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Người Lập Báo Cáo',
                        style: pw.TextStyle(font: fontBold, fontSize: 10),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        '(Ký, ghi rõ họ tên)',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 8,
                          fontStyle: pw.FontStyle.italic,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.SizedBox(height: 45),
                      pw.Text(
                        'Bộ phận Hành chính Nhân sự',
                        style: pw.TextStyle(font: fontBold, fontSize: 10),
                      ),
                    ],
                  ),
                  pw.SizedBox(width: 30),
                ],
              ),
            ];
          },
        ),
      );

      // Đóng loading dialog
      if (context.mounted) Navigator.pop(context);

      // Mở màn hình xem trước bản in (Print Preview) và lưu/in
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Danh_sach_nhan_vien_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      // Đóng loading dialog nếu có lỗi
      if (context.mounted) Navigator.pop(context);
      
      // Hiển thị thông báo lỗi
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tạo file PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Hàm xây dựng các ô trong bảng PDF
  pw.Widget _buildCell(String text, pw.Font font, {bool isHeader = false, bool alignLeft = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: pw.Text(
        text,
        textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 8.5 : 8,
          color: isHeader ? PdfColors.black : PdfColors.grey900,
        ),
      ),
    );
  }
}

