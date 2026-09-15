import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import 'generate/generate_screen.dart';
import 'history/history_screen.dart';
import 'scan/scan_screen.dart';

/// Screen chính của ứng dụng — quản lý điều hướng 3 tabs qua BottomNavigationBar.
///
/// Dùng `IndexedStack` để giữ state của cả 3 screen con.
/// Khi chuyển tab, screen cũ không bị dispose → ví dụ: đang quét QR,
/// chuyển sang tab History rồi quay lại thì camera vẫn hoạt động bình thường.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Index của tab đang hiển thị: 0=Quét, 1=Tạo, 2=Lịch sử.
  int _currentIndex = 0;

  /// Danh sách 3 screen — tạo 1 lần, tái sử dụng qua IndexedStack.
  final List<Widget> _screens = const [
    ScanScreen(),
    GenerateScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack hiển thị 1 screen tại 1 thời điểm dựa trên index,
      // nhưng giữ nguyên state của tất cả screen trong danh sách.
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_rounded),
            activeIcon: Icon(Icons.qr_code_scanner_rounded),
            label: AppStrings.tabScan,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_rounded),
            activeIcon: Icon(Icons.qr_code_rounded),
            label: AppStrings.tabGenerate,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            activeIcon: Icon(Icons.history_rounded),
            label: AppStrings.tabHistory,
          ),
        ],
      ),
    );
  }
}
