import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'about_page.dart';
import 'co_threshold_page.dart';
import 'device_page.dart';
import 'notification_settings_page.dart';
import 'wifi_settings_page.dart';

const Color _track = Color(0xFFE6F0EA);

// Contoh nilai. Ganti dengan status asli dari Firebase / pengaturan tersimpan.
const bool _deviceConnected = true;
const String _thresholdText = '25 ppm';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
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
                const _Header(),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                    ),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 32),
                      children: [
                        const _SectionTitle('Koneksi'),
                        const SizedBox(height: 10),
                        _SettingsGroup(
                          children: [
                            _SettingsRow(
                              icon: Icons.developer_board_rounded,
                              title: 'Perangkat ESP32',
                              subtitle: 'Lihat dan hubungkan alat pendeteksi',
                              trailingText: _deviceConnected
                                  ? 'Terhubung'
                                  : 'Belum terhubung',
                              trailingColor: _deviceConnected
                                  ? AppColors.online
                                  : AppColors.offline,
                              onTap: () => _open(context, const DevicePage()),
                            ),
                            _SettingsRow(
                              icon: Icons.wifi_rounded,
                              title: 'Wi-Fi',
                              subtitle: 'Atur jaringan untuk perangkat',
                              onTap: () =>
                                  _open(context, const WifiSettingsPage()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const _SectionTitle('Peringatan'),
                        const SizedBox(height: 10),
                        _SettingsGroup(
                          children: [
                            _SettingsRow(
                              icon: Icons.notifications_none_rounded,
                              title: 'Notifikasi',
                              subtitle: 'Atur pesan dan suara peringatan',
                              onTap: () => _open(
                                context,
                                const NotificationSettingsPage(),
                              ),
                            ),
                            _SettingsRow(
                              icon: Icons.speed_rounded,
                              title: 'Batas kadar CO',
                              subtitle: 'Peringatan muncul di atas batas ini',
                              trailingText: _thresholdText,
                              onTap: () =>
                                  _open(context, const CoThresholdPage()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        const _SectionTitle('Lainnya'),
                        const SizedBox(height: 10),
                        _SettingsGroup(
                          children: [
                            _SettingsRow(
                              icon: Icons.info_outline_rounded,
                              title: 'Tentang aplikasi',
                              subtitle: 'Versi 1.0.0',
                              onTap: () => _open(context, const AboutPage()),
                            ),
                          ],
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
}

// ───────────────────────── Header ─────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
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
              Icons.tune_rounded,
              color: AppColors.primaryLight,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengaturan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Atur perangkat dan peringatan',
                  style: TextStyle(
                    color: AppColors.onDarkMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Menu berkelompok ─────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppColors.goldGradient,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 70,
                  color: _track,
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingText,
    this.trailingColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? trailingText;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 68),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingText != null) ...[
                const SizedBox(width: 8),
                Text(
                  trailingText!,
                  style: TextStyle(
                    color: trailingColor ?? AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}