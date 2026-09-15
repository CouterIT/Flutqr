import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'services/storage_service.dart';

/// Điểm khởi đầu của ứng dụng.
///
/// `WidgetsFlutterBinding.ensureInitialized()` phải được gọi trước
/// các thao tác async trong `main()` vì Flutter cần khởi tạo
/// binding trước khi có thể chạy bất kỳ code nào liên quan đến framework.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo SharedPreferences trước khi runApp.
  // StorageService cần sẵn sàng để các screen đọc/ghi dữ liệu ngay lập tức.
  await StorageService.init();

  runApp(const FlutQrApp());
}

/// Widget gốc của ứng dụng — cấu hình MaterialApp với theme và home screen.
class FlutQrApp extends StatelessWidget {
  const FlutQrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
