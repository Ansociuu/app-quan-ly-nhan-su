import 'package:flutter/material.dart';
import 'dart:math';
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

    final List<String> trinhDoOptions = [
      'Trung cấp',
      'Cao đẳng',
      'Đại học',
      'Thạc sĩ',
      'Tiến sĩ',
      'Khác'
    ];

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
}
