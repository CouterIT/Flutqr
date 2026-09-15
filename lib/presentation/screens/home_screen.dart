import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import 'generate/generate_screen.dart';
import 'history/history_screen.dart';
import 'scan/scan_screen.dart';

/// Main scaffold container with BottomNavigationBar navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ScanScreen(),
    GenerateScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
