import 'package:flutter/material.dart';
import 'data/app_data.dart';
import 'screens/home_screen.dart';

void main() {
  // Đảm bảo Flutter framework được khởi tạo trước khi gọi SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();
  
  final appData = AppData();
  runApp(
    AppDataProvider(
      appData: appData,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = AppDataProvider.of(context);

    // Xây dựng Theme Sáng
    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.light,
        primary: Colors.deepPurple,
        secondary: Colors.teal,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FE), // Nền sáng dịu mát mắt
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
      ),
    );

    // Xây dựng Theme Tối
    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
        primary: Colors.deepPurple[300]!,
        secondary: Colors.teal[300]!,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212), // Màu nền tối dễ chịu cho mắt
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E1E), // Màu card tối nổi bật trên nền scaffold
        surfaceTintColor: Color(0xFF1E1E1E),
        elevation: 4,
        shadowColor: Colors.black38,
      ),
    );

    return MaterialApp(
      title: 'Quản Lý Nhân Sự (HRM)',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: appData.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Áp dụng Cỡ chữ Động toàn hệ thống bằng cách ghi đè textScaleFactor trong MediaQuery
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(appData.fontSizeMultiplier),
          ),
          child: appData.isLoading 
              ? const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
