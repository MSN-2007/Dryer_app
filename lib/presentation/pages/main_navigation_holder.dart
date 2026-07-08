import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'home/home_page.dart';
import 'library/library_page.dart';
import 'devices/devices_page.dart';
import 'start_cycle/start_cycle_page.dart';
import 'profile/profile_page.dart';

class MainNavigationHolder extends StatefulWidget {
  const MainNavigationHolder({super.key});

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const LibraryPage(),
    const DevicesPage(),
    const StartCyclePage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedItemColor: isDark ? AppColors.primaryLight : AppColors.primary,
          unselectedItemColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Library',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_input_hdmi_outlined),
              activeIcon: Icon(Icons.settings_input_hdmi),
              label: 'Devices',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_outline),
              activeIcon: Icon(Icons.play_circle_filled),
              label: 'Start Cycle',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
