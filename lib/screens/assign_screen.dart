import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/employee.dart';
import '../models/position.dart';

class AssignScreen extends StatefulWidget {
  const AssignScreen({super.key});

  @override
  State<AssignScreen> createState() => _AssignScreenState();
}

class _AssignScreenState extends State<AssignScreen> {
  String? _selectedEmployeeId;
  String? _selectedPositionId;

  @override
  Widget build(BuildContext context) {
    final appData = AppDataProvider.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final employees = appData.employees;
    final positions = appData.positions;
    final assignments = appData.employeePosition;

    // Lọc danh sách nhân viên đã có chức vụ để hiển thị bên dưới
    final assignedEmployees = employees.where((emp) => assignments.containsKey(emp.maNV)).toList();

    // Reset dropdown nếu ID không còn tồn tại trong danh sách nguồn (phòng khi bị xóa)
    if (_selectedEmployeeId != null && !employees.any((e) => e.maNV == _selectedEmployeeId)) {
      _selectedEmployeeId = null;
    }
    if (_selectedPositionId != null && !positions.any((p) => p.maCV == _selectedPositionId)) {
      _selectedPositionId = null;
    }

    // Tự động chọn giá trị đầu tiên nếu dropdown chưa có giá trị
    if (_selectedEmployeeId == null && employees.isNotEmpty) {
      _selectedEmployeeId = employees.first.maNV;
    }
    if (_selectedPositionId == null && positions.isNotEmpty) {
      _selectedPositionId = positions.first.maCV;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bổ nhiệm Chức vụ'),
        elevation: 0,
      ),
      body: employees.isEmpty || positions.isEmpty
          ? _buildSetupRequiredState(theme, employees.isEmpty, positions.isEmpty)
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Form gán chức vụ ở phía trên
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GÁN CHỨC VỤ MỚI',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Chọn nhân viên Dropdown
                            const Text(
                              'Chọn nhân viên:',
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(12),
                                color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.grey[50],
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedEmployeeId,
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                                  items: employees.map((Employee emp) {
                                    final currentPos = appData.getPositionNameOfEmployee(emp.maNV);
                                    return DropdownMenuItem<String>(
                                      value: emp.maNV,
                                      child: Text(
                                        '${emp.hoTen} (${emp.maNV}) - [$currentPos]',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedEmployeeId = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Chọn chức vụ Dropdown
                            const Text(
                              'Chọn chức vụ gán:',
                              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(12),
                                color: isDark ? theme.colorScheme.surfaceContainerHigh : Colors.grey[50],
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedPositionId,
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                                  items: positions.map((Position pos) {
                                    return DropdownMenuItem<String>(
                                      value: pos.maCV,
                                      child: Text('${pos.tenCV} (${pos.maCV})'),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPositionId = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Nút Gán
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  if (_selectedEmployeeId != null && _selectedPositionId != null) {
                                    final emp = employees.firstWhere((e) => e.maNV == _selectedEmployeeId);
                                    final pos = positions.firstWhere((p) => p.maCV == _selectedPositionId);
                                    
                                    appData.assignPosition(_selectedEmployeeId!, _selectedPositionId!);
                                    
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Đã bổ nhiệm ${emp.hoTen} làm ${pos.tenCV}!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.assignment_turned_in),
                                label: const Text(
                                  'GÁN CHỨC VỤ',
                                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 2. Danh sách nhân viên đã có chức vụ
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'DANH SÁCH BỔ NHIỆM (${assignedEmployees.length})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  assignedEmployees.isEmpty
                      ? _buildEmptyAssignmentsState(theme)
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: assignedEmployees.length,
                          itemBuilder: (context, index) {
                            final emp = assignedEmployees[index];
                            final posId = assignments[emp.maNV]!;
                            final pos = positions.firstWhere(
                              (p) => p.maCV == posId,
                              orElse: () => Position(maCV: posId, tenCV: 'Không xác định', moTa: ''),
                            );

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Color(emp.avatarColorValue),
                                  child: Text(
                                    emp.hoTen.trim().isNotEmpty ? emp.hoTen.trim()[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(
                                  emp.hoTen,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Row(
                                  children: [
                                    const Icon(Icons.arrow_right_alt, size: 16, color: Colors.blueGrey),
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        pos.tenCV,
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.link_off, color: Colors.red),
                                  tooltip: 'Hủy gán chức vụ',
                                  onPressed: () {
                                    _showUnassignConfirmDialog(context, appData, emp, pos.tenCV);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // Yêu cầu thiết lập trước khi gán
  Widget _buildSetupRequiredState(ThemeData theme, bool empEmpty, bool posEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 80,
              color: theme.colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              'Yêu Cầu Chuẩn Bị Dữ Liệu',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Để thực hiện gán chức vụ, hệ thống yêu cầu phải có ít nhất 1 nhân viên và 1 chức vụ.\nHiện tại đang thiếu:',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
            ),
            const SizedBox(height: 12),
            if (empEmpty)
              Chip(
                avatar: const Icon(Icons.error_outline, color: Colors.red),
                label: const Text('Chưa có nhân viên nào'),
                backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.5),
              ),
            if (posEmpty)
              Chip(
                avatar: const Icon(Icons.error_outline, color: Colors.red),
                label: const Text('Chưa có chức vụ nào'),
                backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.5),
              ),
            const SizedBox(height: 24),
            const Text(
              'Vui lòng quay lại Trang chủ, truy cập mục "Quản Lý Nhân Viên" hoặc "Quản Lý Chức Vụ" để thêm dữ liệu trước.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAssignmentsState(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.assignment_late_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Chưa có nhân viên nào được gán chức vụ.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // Xác nhận hủy gán chức vụ
  void _showUnassignConfirmDialog(BuildContext context, AppData appData, Employee emp, String posName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Hủy gán chức vụ'),
          content: Text.rich(
            TextSpan(
              text: 'Bạn có chắc chắn muốn gỡ chức vụ ',
              children: [
                TextSpan(text: posName, style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: ' khỏi nhân viên '),
                TextSpan(text: emp.hoTen, style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: '? Nhân viên này sẽ tạm thời không có chức vụ.'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy bỏ'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                appData.unassignPosition(emp.maNV);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã hủy gán chức vụ đối với ${emp.hoTen}.'),
                    backgroundColor: Colors.blueGrey,
                  ),
                );
              },
              child: const Text('Đồng ý hủy'),
            ),
          ],
        );
      },
    );
  }
}
