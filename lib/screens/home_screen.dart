import 'package:flutter/material.dart';
import '../data/app_data.dart';
import 'employee_screen.dart';
import 'position_screen.dart';
import 'assign_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appData = AppDataProvider.of(context);
    final theme = Theme.of(context);

    // Danh sách 5 màn hình tương ứng với 5 tabs, được bọc trong IndexedStack để giữ trạng thái
    final List<Widget> tabs = [
      DashboardTab(onNavigate: (index) {
        setState(() {
          _currentIndex = index;
        });
      }),
      const EmployeeScreen(),
      const PositionScreen(),
      const AssignScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        elevation: 8,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_alt_rounded),
            label: 'Nhân viên',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_outline),
            selectedIcon: Icon(Icons.work_rounded),
            label: 'Chức vụ',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_ind_outlined),
            selectedIcon: Icon(Icons.assignment_ind_rounded),
            label: 'Bổ nhiệm',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}

// Widget DashboardTab (Giao diện cũ của HomeScreen nhưng hoạt động như một Tab con)
class DashboardTab extends StatelessWidget {
  final ValueChanged<int> onNavigate;

  const DashboardTab({
    super.key,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final appData = AppDataProvider.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Lấy thống kê dữ liệu thực tế
    final totalEmployees = appData.employees.length;
    final totalPositions = appData.positions.length;
    final stats = appData.getPositionStatistics();

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Banner chào mừng Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [theme.colorScheme.primary.withOpacity(0.8), theme.colorScheme.tertiary.withOpacity(0.8)]
                      : [theme.colorScheme.primary, theme.colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Xin chào,',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Nhà Quản Trị',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      // Icon trang trí hình đại diện quản trị sử dụng ảnh avatar mẫu từ assets
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/avatars/avatar5.png',
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Hộp thông tin nhanh (Quick Metrics)
                  Row(
                    children: [
                      _buildQuickMetric(
                        context,
                        'Tổng Nhân Viên',
                        '$totalEmployees',
                        Icons.people,
                      ),
                      const SizedBox(width: 16),
                      _buildQuickMetric(
                        context,
                        'Tổng Chức Vụ',
                        '$totalPositions',
                        Icons.work,
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Khu vực Dashboard Thống kê Biểu đồ
            _buildSectionTitle(context, 'Dashboard Thống Kê'),
            _buildStatisticsChart(context, stats, totalEmployees),

            const SizedBox(height: 16),

            // 3. Menu chức năng Grid (Nhấn vào sẽ chuyển Tab tương ứng)
            _buildSectionTitle(context, 'Phím Tắt Nhanh'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.15,
                children: [
                  _buildMenuCard(
                    context: context,
                    title: 'Quản Lý Nhân Viên',
                    subtitle: 'Xem, thêm, sửa, xóa thông tin',
                    icon: Icons.people_alt_rounded,
                    color: Colors.indigo,
                    onTap: () => onNavigate(1), // Chuyển sang Tab 1 (Nhân viên)
                  ),
                  _buildMenuCard(
                    context: context,
                    title: 'Quản Lý Chức Vụ',
                    subtitle: 'Thiết lập danh mục chức vụ',
                    icon: Icons.work_rounded,
                    color: Colors.teal,
                    onTap: () => onNavigate(2), // Chuyển sang Tab 2 (Chức vụ)
                  ),
                  _buildMenuCard(
                    context: context,
                    title: 'Gán Chức Vụ',
                    subtitle: 'Bổ nhiệm vai trò nhân viên',
                    icon: Icons.assignment_ind_rounded,
                    color: Colors.amber[800]!,
                    onTap: () => onNavigate(3), // Chuyển sang Tab 3 (Gán chức vụ)
                  ),
                  _buildMenuCard(
                    context: context,
                    title: 'Cài Đặt Hệ Thống',
                    subtitle: 'Giao diện, cỡ chữ & thông tin',
                    icon: Icons.settings_rounded,
                    color: Colors.blueGrey,
                    onTap: () => onNavigate(4), // Chuyển sang Tab 4 (Cài đặt)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildQuickMetric(
      BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.25 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isDark ? color.withOpacity(0.9) : color,
                  size: 26,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      fontSize: 10,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Biểu đồ thống kê nhân sự tự vẽ chuyên nghiệp
  Widget _buildStatisticsChart(
      BuildContext context, Map<String, int> stats, int totalEmployees) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (totalEmployees == 0) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'Chưa có nhân viên nào để thống kê.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tỷ lệ nhân viên theo Chức vụ',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Trục biểu đồ dạng cột nằm ngang
            ...stats.entries.map((entry) {
              final title = entry.key;
              final count = entry.value;
              final percentage = count / totalEmployees;

              Color barColor = theme.colorScheme.primary;
              if (title == 'Chưa gán') {
                barColor = Colors.grey;
              } else if (title.contains('Trưởng')) {
                barColor = Colors.orange;
              } else if (title.contains('Phó')) {
                barColor = Colors.blue;
              } else {
                barColor = Colors.teal;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                        Text(
                          '$count NV (${(percentage * 100).toStringAsFixed(0)}%)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Thanh biểu đồ
                    Stack(
                      children: [
                        Container(
                          height: 10,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percentage,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [barColor.withOpacity(0.7), barColor],
                              ),
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: barColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
