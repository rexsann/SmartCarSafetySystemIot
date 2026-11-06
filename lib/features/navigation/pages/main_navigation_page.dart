import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../dashboard/pages/dashboard_page.dart';
import '../../history/pages/history_page.dart';
import '../../notifications/pages/notifications_page.dart';
import '../../profile/pages/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _hasUnreadNotifications = true;

  late final AnimationController _pageFadeController;
  late final Animation<double> _pageFade;

  final List<Widget> _pages = const [
    DashboardPage(),
    HistoryPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  static const List<_NavItem> _items = [
    _NavItem(
      label: 'Beranda',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _NavItem(
      label: 'Grafik',
      icon: Icons.show_chart_rounded,
      selectedIcon: Icons.query_stats_rounded,
    ),
    _NavItem(
      label: 'Notifikasi',
      icon: Icons.notifications_none_rounded,
      selectedIcon: Icons.notifications_rounded,
    ),
    _NavItem(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      value: 1,
    );
    _pageFade = CurvedAnimation(
      parent: _pageFadeController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageFadeController.dispose();
    super.dispose();
  }

  void _onDestinationSelected(int index) {
    if (index == _selectedIndex) return;

    HapticFeedback.selectionClick();

    setState(() {
      _selectedIndex = index;
      if (index == 2) {
        _hasUnreadNotifications = false;
      }
    });

    // Halaman baru muncul dengan fade + geser halus
    _pageFadeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _pageFade,
        builder: (context, child) {
          return Opacity(
            opacity: 0.35 + 0.65 * _pageFade.value,
            child: Transform.translate(
              offset: Offset(0, 10 * (1 - _pageFade.value)),
              child: child,
            ),
          );
        },
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: _PremiumNavBar(
        items: _items,
        selectedIndex: _selectedIndex,
        showBadgeAt: _hasUnreadNotifications ? 2 : null,
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

class _PremiumNavBar extends StatelessWidget {
  const _PremiumNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.showBadgeAt,
  });

  final List<_NavItem> items;
  final int selectedIndex;
  final int? showBadgeAt;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const primary = AppColors.primary;
    final primaryDeep =
        Color.lerp(AppColors.primary, AppColors.primaryDark, 0.30)!;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.14),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (i) {
              return _NavButton(
                item: items[i],
                selected: i == selectedIndex,
                showBadge: showBadgeAt == i,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primary, primaryDeep],
                ),
                glowColor: primary,
                onTap: () => onSelected(i),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.showBadge,
    required this.gradient,
    required this.glowColor,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final bool showBadge;
  final Gradient gradient;
  final Color glowColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const inactiveColor = AppColors.textSecondary;

    Widget icon = AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: Icon(
        selected ? item.selectedIcon : item.icon,
        key: ValueKey<bool>(selected),
        size: 24,
        color: selected ? Colors.white : inactiveColor,
      ),
    );

    if (showBadge) {
      icon = Badge(
        smallSize: 9,
        backgroundColor: AppColors.danger,
        child: icon,
      );
    }

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          height: 50,
          padding: EdgeInsets.symmetric(horizontal: selected ? 18 : 14),
          decoration: BoxDecoration(
            gradient: selected ? gradient : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                alignment: Alignment.centerLeft,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}