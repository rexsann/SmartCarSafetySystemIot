import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../dashboard/pages/dashboard_page.dart';
import '../../history/pages/history_page.dart';
import '../../profile/pages/settings_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  // IndexedStack menjaga halaman tetap hidup, jadi data dan posisi scroll
  // tidak hilang saat berpindah tab.
  final List<Widget> _pages = const [
    DashboardPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  static const List<_NavItem> _items = [
    _NavItem(
      label: 'Beranda',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _NavItem(
      label: 'Riwayat',
      icon: Icons.show_chart_rounded,
      selectedIcon: Icons.query_stats_rounded,
    ),
    _NavItem(
      label: 'Pengaturan',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
    ),
  ];

  void _onDestinationSelected(int index) {
    if (index == _selectedIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _BottomNav(
        items: _items,
        selectedIndex: _selectedIndex,
        onSelected: _onDestinationSelected,
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          height: 68,
          indicatorColor: AppColors.primary.withValues(alpha: 0.14),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 26,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onSelected,
          destinations: [
            for (final item in items)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
                tooltip: item.label,
              ),
          ],
        ),
      ),
    );
  }
}