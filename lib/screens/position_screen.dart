import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/position.dart';
import '../widgets/position_card.dart';

class PositionScreen extends StatelessWidget {
  const PositionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = AppDataProvider.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục Chức vụ'),
        elevation: 0,
      ),
      body: appData.positions.isEmpty
          ? _buildEmptyState(theme)
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80), // Chừa khoảng trống cho FAB
              itemCount: appData.positions.length,
              itemBuilder: (context, index) {
                final pos = appData.positions[index];
                return PositionCard(
                  position: pos,
                  onEdit: () => _showPositionFormDialog(context, pos),
                  onDelete: () => _showDeleteConfirmDialog(context, appData, pos),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPositionFormDialog(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Thêm chức vụ'),
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
              Icons.work_off_outlined,
              size: 72,
              color: theme.colorScheme.primary.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Danh mục chức vụ trống',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Chưa có chức vụ nào được cấu hình trong hệ thống. Hãy nhấn nút phía dưới để thêm mới.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOG THÊM / SỬA CHỨC VỤ ---
  void _showPositionFormDialog(BuildContext context, Position? existingPos) {
    final appData = AppDataProvider.of(context);
    final isEdit = existingPos != null;

    final formKey = GlobalKey<FormState>();
    final maCVController = TextEditingController(text: existingPos?.maCV ?? '');
    final tenCVController = TextEditingController(text: existingPos?.tenCV ?? '');
    final moTaController = TextEditingController(text: existingPos?.moTa ?? '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                isEdit ? Icons.edit_attributes_outlined : Icons.add_moderator_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(isEdit ? 'Sửa Chức Vụ' : 'Thêm Chức Vụ Mới'),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mã CV (Khóa chính)
                  TextFormField(
                    controller: maCVController,
                    enabled: !isEdit,
                    decoration: InputDecoration(
                      labelText: 'Mã chức vụ',
                      hintText: 'Ví dụ: CV04',
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Mã chức vụ không được để trống';
                      }
                      if (!isEdit && appData.positions.any((p) => p.maCV.toLowerCase() == value.trim().toLowerCase())) {
                        return 'Mã chức vụ này đã tồn tại';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tên CV
                  TextFormField(
                    controller: tenCVController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Tên chức vụ',
                      hintText: 'Ví dụ: Trưởng phòng Marketing',
                      prefixIcon: const Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Tên chức vụ không được để trống';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Mô tả chi tiết
                  TextFormField(
                    controller: moTaController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Mô tả công việc',
                      hintText: 'Nhập mô tả chi tiết quyền hạn và nghĩa vụ...',
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
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
                  final pos = Position(
                    maCV: maCVController.text.trim(),
                    tenCV: tenCVController.text.trim(),
                    moTa: moTaController.text.trim(),
                  );

                  bool success;
                  if (isEdit) {
                    success = appData.updatePosition(pos);
                  } else {
                    success = appData.addPosition(pos);
                  }

                  if (success) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit
                            ? 'Cập nhật chức vụ thành công!'
                            : 'Thêm chức vụ mới thành công!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lỗi: Có lỗi xảy ra trong quá trình lưu dữ liệu!'),
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
  }

  // --- DIALOG XÁC NHẬN XÓA CHỨC VỤ ---
  void _showDeleteConfirmDialog(BuildContext context, AppData appData, Position pos) {
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
              text: 'Bạn có chắc muốn xóa chức vụ ',
              children: [
                TextSpan(
                  text: pos.tenCV,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: ' (Mã: ${pos.maCV}) không?\n\n',
                ),
                const TextSpan(
                  text: 'CẢNH BÁO: Tất cả nhân viên đang giữ chức vụ này sẽ bị đưa về trạng thái "Chưa gán chức vụ"!',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
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
                appData.deletePosition(pos.maCV);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Đã xóa chức vụ ${pos.tenCV}.'),
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
