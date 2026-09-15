import 'package:flutter/material.dart';

import 'core/constants/app_strings.dart';
import 'core/constants/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

  runApp(const FlutQrApp());
}

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
