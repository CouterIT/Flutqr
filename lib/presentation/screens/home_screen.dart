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

  final GlobalKey<ScanScreenState> _scanKey = GlobalKey<ScanScreenState>();
  final GlobalKey<GenerateScreenState> _generateKey = GlobalKey<GenerateScreenState>();
  final GlobalKey<HistoryScreenState> _historyKey = GlobalKey<HistoryScreenState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ScanScreen(key: _scanKey),
          GenerateScreen(key: _generateKey),
          HistoryScreen(key: _historyKey),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          // Pause camera khi rời tab Scan, resume khi quay lại
          if (_currentIndex == 0 && index != 0) {
            _scanKey.currentState?.pauseCamera();
          } else if (_currentIndex != 0 && index == 0) {
            _scanKey.currentState?.resumeCamera();
          }

          if (_currentIndex == 1 || index == 1) {
            _generateKey.currentState?.resetState();
          }
          if (index == 2) {
            _historyKey.currentState?.resetState();
          }
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
