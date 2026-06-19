import 'package:flutter/material.dart';
import '../data/app_data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = AppDataProvider.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt & Thông tin'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Giao diện
            _buildSectionHeader(context, 'Giao diện & Cấu hình'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  // Switch Dark Mode
                  ListTile(
                    leading: Icon(
                      appData.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text('Chế độ tối (Dark Mode)'),
                    subtitle: Text(
                      appData.isDarkMode
                          ? 'Đang sử dụng giao diện tối'
                          : 'Đang sử dụng giao diện sáng',
                    ),
                    trailing: Switch.adaptive(
                      value: appData.isDarkMode,
                      onChanged: (value) {
                        appData.toggleDarkMode(value);
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  // Slider Cỡ Chữ
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.format_size, color: theme.colorScheme.primary),
                                const SizedBox(width: 16),
                                const Text(
                                  'Kích thước chữ',
                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                ),
                              ],
                            ),
                            Text(
                              '${(appData.fontSizeMultiplier * 100).toInt()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Slider(
                          value: appData.fontSizeMultiplier,
                          min: 0.8,
                          max: 1.5,
                          divisions: 7, // 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5
                          label: '${(appData.fontSizeMultiplier * 100).toInt()}%',
                          onChanged: (value) {
                            appData.setFontSizeMultiplier(value);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Xem trước cỡ chữ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bản xem trước văn bản',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kéo thanh trượt phía trên để thay đổi kích thước chữ của toàn bộ ứng dụng. Điều này giúp người lớn tuổi hoặc người có thị lực kém dễ dàng đọc nội dung hơn.',
                      style: TextStyle(height: 1.4),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Section 2: Thông tin ứng dụng
            _buildSectionHeader(context, 'Thông tin ứng dụng'),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildInfoRow(context, Icons.info_outline, 'Tên ứng dụng', 'Flutter HRM App'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoRow(context, Icons.adb, 'Phiên bản', '1.0.0 (Build 1)'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoRow(context, Icons.developer_mode, 'Công nghệ', 'Flutter SDK (Dart 3)'),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildInfoRow(
                    context,
                    Icons.business,
                    'Mục đích',
                    'Quản lý nhân sự chuyên nghiệp cho doanh nghiệp vừa và nhỏ (SMEs)',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            // Footer trang trí
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2026 HRM System Solution',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.secondary),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(value),
    );
  }
}
