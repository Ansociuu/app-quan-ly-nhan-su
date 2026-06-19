import 'package:flutter/material.dart';
import '../models/employee.dart';

class EmployeeCard extends StatelessWidget {
  final Employee employee;
  final String positionName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.positionName,
    required this.onEdit,
    required this.onDelete,
  });

  // Lấy chữ cái đầu của Họ và Tên (Ví dụ: Nguyễn Văn A -> NA)
  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Màu sắc của badge chức vụ
    Color badgeColor;
    Color badgeTextColor;
    if (positionName.contains('Trưởng')) {
      badgeColor = Colors.orange.withOpacity(isDark ? 0.25 : 0.15);
      badgeTextColor = isDark ? Colors.orange[300]! : Colors.orange[900]!;
    } else if (positionName.contains('Phó')) {
      badgeColor = Colors.blue.withOpacity(isDark ? 0.25 : 0.15);
      badgeTextColor = isDark ? Colors.blue[300]! : Colors.blue[900]!;
    } else if (positionName == 'Chưa gán chức vụ') {
      badgeColor = Colors.grey.withOpacity(isDark ? 0.25 : 0.15);
      badgeTextColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;
    } else {
      badgeColor = Colors.teal.withOpacity(isDark ? 0.25 : 0.15);
      badgeTextColor = isDark ? Colors.teal[300]! : Colors.teal[900]!;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng đầu: Avatar, Tên & Chức vụ badge
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(employee.avatarColorValue).withOpacity(0.15),
                  child: ClipOval(
                    child: Image.asset(
                      employee.avatarAssetPath,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          _getInitials(employee.hoTen),
                          style: TextStyle(
                            color: Color(employee.avatarColorValue),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.hoTen,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mã: ${employee.maNV}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge chức vụ
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    positionName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: badgeTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Divider(height: 1, thickness: 0.5),
            ),
            // Dòng hai: Chi tiết (Năm sinh, Giới tính, Trình độ, Quê quán)
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildInfoItem(context, Icons.wc, employee.gioiTinh),
                _buildInfoItem(context, Icons.cake, '${employee.namSinh}'),
                _buildInfoItem(context, Icons.school, employee.trinhDo),
                _buildInfoItem(context, Icons.location_on, employee.queQuan),
              ],
            ),
            const SizedBox(height: 12),
            // Dòng ba: Các nút hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Sửa'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.error),
                  label: Text('Xóa', style: TextStyle(color: theme.colorScheme.error)),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary.withOpacity(0.7)),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.85),
          ),
        ),
      ],
    );
  }
}
