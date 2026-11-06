import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

// Warna lokal (sama seperti Dashboard)
const Color _mutedLight = Color(0xFF9AB0A5);

enum _Category { all, warning, system }

class _NotificationItem {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String time;
  final _Category category;

  const _NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.time,
    required this.category,
  });
}

// Data contoh — ganti dengan data dari ESP32 / Blynk.
final _items = <_NotificationItem>[
  _NotificationItem(
    icon: Icons.check_rounded,
    color: AppColors.safe,
    title: 'Kadar CO normal',
    description: 'CO berada dalam batas aman.',
    time: '09:00',
    category: _Category.system,
  ),
  _NotificationItem(
    icon: Icons.warning_amber_rounded,
    color: AppColors.danger,
    title: 'Kadar CO meningkat',
    description: 'CO melebihi batas aman. 150 ppm terdeteksi.',
    time: '08:30',
    category: _Category.warning,
  ),
  _NotificationItem(
    icon: Icons.location_on_outlined,
    color: AppColors.info,
    title: 'Lokasi terhubung',
    description: 'GPS berhasil mengirim lokasi kendaraan dengan akurat.',
    time: '08:20',
    category: _Category.system,
  ),
  _NotificationItem(
    icon: Icons.wifi_rounded,
    color: AppColors.safe,
    title: 'Koneksi berhasil dibuat',
    description: 'IoT terhubung dengan aman.',
    time: '08:10',
    category: _Category.system,
  ),
];

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  _Category _selected = _Category.all;
  final Set<_NotificationItem> _read = {};

  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
  }

  int get _unreadCount => _items.where((e) => !_read.contains(e)).length;

  // Muncul bertahap: fade + geser dari bawah
  Widget _stagger(double start, Widget child) {
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, _) {
        final t = Curves.easeOutCubic.transform(
          ((_enter.value - start) / 0.45).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selected == _Category.all
        ? _items
        : _items.where((e) => e.category == _selected).toList();

    return Scaffold(
      backgroundColor: AppColors.darkMid,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.darkGradient),
            ),
          ),
          // Cahaya lembut di pojok header
          Positioned(
            top: -90,
            right: -70,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.22),
                    AppColors.primary.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _stagger(0.0, _buildHeader()),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                          child: _stagger(
                            0.10,
                            _FilterBar(
                              selected: _selected,
                              onChanged: (c) => setState(() => _selected = c),
                            ),
                          ),
                        ),
                        Expanded(
                          child: filtered.isEmpty
                              ? const _EmptyState()
                              : ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 16, 16, 24),
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (_, i) {
                                    final item = filtered[i];
                                    return _stagger(
                                      0.20 + i * 0.08,
                                      _NotificationTile(
                                        item: item,
                                        unread: !_read.contains(item),
                                        onTap: () =>
                                            setState(() => _read.add(item)),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Header ─────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 22),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDeep, Color(0xFF062016)],
              ),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.7),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 16,
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.primaryLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifikasi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _unreadCount == 0
                      ? 'Semua sudah dibaca'
                      : '$_unreadCount belum dibaca',
                  style: const TextStyle(
                    color: AppColors.onDarkMuted,
                    fontSize: 12,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
            ),
            child: IconButton(
              tooltip: 'Tandai semua dibaca',
              icon: const Icon(
                Icons.done_all_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () => setState(() => _read.addAll(_items)),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Filter ─────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final _Category selected;
  final ValueChanged<_Category> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = {
      _Category.all: 'Semua',
      _Category.warning: 'Peringatan',
      _Category.system: 'Sistem',
    };

    return Row(
      children: [
        for (final c in _Category.values) ...[
          _FilterChip(
            label: labels[c]!,
            active: selected == c,
            onTap: () => onChanged(c),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

// ───────────────────────── Item notifikasi ─────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.unread,
    required this.onTap,
  });

  final _NotificationItem item;
  final bool unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: unread ? item.color.withValues(alpha: 0.25) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: (unread ? item.color : AppColors.primaryDark)
                .withValues(alpha: unread ? 0.10 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: item.color.withValues(alpha: 0.2)),
                  ),
                  child: Icon(item.icon, color: item.color, size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14.5,
                                fontWeight:
                                    unread ? FontWeight.w800 : FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.time,
                            style: const TextStyle(
                              color: _mutedLight,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unread) ...[
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: _mutedLight,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum ada notifikasi',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}