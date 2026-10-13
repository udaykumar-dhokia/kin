import 'package:flutter/material.dart';
import '../../bills/screens/bills_list_screen.dart';
import '../../categories/screens/categories_screen.dart';
import '../../dashboard/screens/today_screen.dart';
import '../../family/screens/family_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../widgets/kin_bottom_nav.dart';

class MainShellScreen extends StatefulWidget {
  final int initialIndex;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const TodayScreen(),
      CategoriesScreen(onNavigateTab: _onTabSelected),
      const BillsListScreen(),
      const FamilyScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: KinBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
