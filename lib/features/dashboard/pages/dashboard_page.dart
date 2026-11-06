import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  // Data contoh — ganti dengan data dari ESP32 / Blynk.
  double coLevel = 12;
  bool espConnected = true;
  bool ledActive = false;
  bool buzzerEnabled = false;

  static const double _maxPpm = 200;

  // Warna lokal yang hanya dipakai di halaman ini
  static const Color _mutedLight = Color(0xFF9AB0A5);
  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _goldDeep = Color(0xFFB8963E);

  late final AnimationController _enter;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _enter.dispose();
    _pulse.dispose();
    super.dispose();
  }

  _Condition get condition {
    if (coLevel >= 50) {
      return const _Condition(
        label: 'Bahaya',
        title: 'Bahaya CO!',
        message: 'Kadar CO sangat tinggi. Buka jendela dan keluar dari mobil.',
        color: AppColors.danger,
        icon: Icons.warning_rounded,
        isDanger: true,
      );
    }
    if (coLevel >= 25) {
      return const _Condition(
        label: 'Waspada',
        title: 'Kondisi Waspada',
        message: 'Kadar CO meningkat, periksa kondisi kabin.',
        color: AppColors.warning,
        icon: Icons.error_outline_rounded,
      );
    }
    return const _Condition(
      label: 'Normal',
      title: 'Kondisi Aman',
      message: 'Kadar CO masih dalam batas normal.',
      color: AppColors.safe,
      icon: Icons.check_rounded,
    );
  }

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
          child: Transform.translate(offset: Offset(0, 22 * (1 - t)), child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = condition;

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
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      children: [
                        _stagger(0.15, _buildGaugeCard(c)),
                        const SizedBox(height: 14),
                        _stagger(0.30, _buildSectionTitle('Status Perangkat')),
                        const SizedBox(height: 10),
                        _buildDeviceGrid(),
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
            child: const Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.shield_rounded, color: AppColors.primaryLight, size: 34),
                Icon(Icons.directions_car_rounded, color: Colors.white, size: 17),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Car Safety',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _connectionDot(),
                    const SizedBox(width: 6),
                    Text(
                      espConnected ? 'ESP32 terhubung' : 'ESP32 terputus',
                      style: const TextStyle(
                        color: AppColors.onDarkMuted,
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
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
              onPressed: () {},
              tooltip: 'Pengaturan',
              icon: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _connectionDot() {
    final color = espConnected ? AppColors.online : AppColors.offline;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final v = espConnected ? _pulse.value : 0.0;
        return SizedBox(
          width: 14,
          height: 14,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 7 + 7 * v,
                height: 7 + 7 * v,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: (1 - v) * 0.35),
                ),
              ),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
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
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ───────────────────────── Kartu gauge ─────────────────────────

  Widget _buildGaugeCard(_Condition c) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: c.color.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kadar CO Kabin',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Dipantau secara real-time',
                      style: TextStyle(color: _mutedLight, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _pill(c.label, c.color),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 230,
            height: 230,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: coLevel),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _pulse,
                        builder: (context, _) => CustomPaint(
                          painter: _GaugePainter(
                            value: v,
                            max: _maxPpm,
                            color: c.color,
                            pulse: c.isDanger
                                ? 0.5 + 0.5 * math.sin(_pulse.value * 2 * math.pi)
                                : 0,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          v.toStringAsFixed(0),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 56,
                            height: 1.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'ppm',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const Positioned(
                      left: 36,
                      bottom: 2,
                      child: Text(
                        '0',
                        style: TextStyle(color: _mutedLight, fontSize: 11),
                      ),
                    ),
                    const Positioned(
                      right: 30,
                      bottom: 2,
                      child: Text(
                        '200',
                        style: TextStyle(color: _mutedLight, fontSize: 11),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          _buildConditionBanner(c),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LegendItem(color: AppColors.safe, label: 'Normal  < 25'),
              _LegendItem(color: AppColors.warning, label: 'Waspada  25-50'),
              _LegendItem(color: AppColors.danger, label: 'Bahaya  > 50'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConditionBanner(_Condition c) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.color.withValues(alpha: 0.13),
            c.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: c.color.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(c.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.title,
                  style: TextStyle(
                    color: c.color,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  c.message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── Status perangkat ─────────────────────────

  Widget _buildDeviceGrid() {
    final tiles = <Widget>[
      _DeviceTile(
        icon: Icons.wifi_rounded,
        color: AppColors.info,
        title: 'Koneksi ESP32',
        value: espConnected ? 'Online' : 'Offline',
        valueColor: espConnected ? AppColors.online : AppColors.offline,
      ),
      const _DeviceTile(
        icon: Icons.battery_5_bar_rounded,
        color: _purple,
        title: 'Baterai',
        value: '12.4 V',
      ),
      _DeviceTile(
        icon: Icons.lightbulb_outline_rounded,
        color: _goldDeep,
        title: 'Status LED',
        value: ledActive ? 'Aktif' : 'Aman',
        valueColor: ledActive ? AppColors.warning : AppColors.safe,
      ),
      _DeviceTile(
        icon: Icons.volume_up_rounded,
        color: AppColors.danger,
        title: 'Buzzer',
        value: buzzerEnabled ? 'ON' : 'OFF',
        valueColor: buzzerEnabled ? AppColors.danger : AppColors.offline,
        trailing: Transform.scale(
          scale: 0.8,
          child: Switch(
            value: buzzerEnabled,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (value) => setState(() => buzzerEnabled = value),
          ),
        ),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (int i = 0; i < tiles.length; i++)
          _stagger(0.38 + i * 0.07, tiles[i]),
      ],
    );
  }

  Widget _pill(String label, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Model & widget kecil ─────────────────────────

class _Condition {
  final String label;
  final String title;
  final String message;
  final Color color;
  final IconData icon;
  final bool isDanger;

  const _Condition({
    required this.label,
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
    this.isDanger = false,
  });
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10.5,
          ),
        ),
      ],
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Gauge ─────────────────────────

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.value,
    required this.max,
    required this.color,
    this.pulse = 0,
  });

  final double value;
  final double max;
  final Color color;
  final double pulse; // 0..1, hanya aktif saat bahaya

  static const double _stroke = 16;
  static const double _startAngle = 3 * math.pi / 4; // 135°
  static const double _totalSweep = 3 * math.pi / 2; // 270°

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - _stroke / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final progress = (value / max).clamp(0.0, 1.0);

    // Jalur latar
    canvas.drawArc(
      rect,
      _startAngle,
      _totalSweep,
      false,
      Paint()
        ..color = const Color(0xFFE6F0EA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round,
    );

    // Garis skala tipis di bagian dalam
    const ticks = 20;
    final inner = radius - _stroke / 2 - 8;
    for (int i = 0; i <= ticks; i++) {
      final a = _startAngle + _totalSweep * i / ticks;
      final major = i % 5 == 0;
      final len = major ? 9.0 : 5.0;
      final active = i / ticks <= progress;
      canvas.drawLine(
        Offset(center.dx + inner * math.cos(a), center.dy + inner * math.sin(a)),
        Offset(
          center.dx + (inner - len) * math.cos(a),
          center.dy + (inner - len) * math.sin(a),
        ),
        Paint()
          ..color = active
              ? color.withValues(alpha: 0.65)
              : const Color(0xFFCFDDD5)
          ..strokeWidth = major ? 1.6 : 1.1
          ..strokeCap = StrokeCap.round,
      );
    }

    final sweep = _totalSweep * progress;
    if (sweep <= 0) return;

    // Cahaya lembut di belakang busur nilai (berdenyut saat bahaya)
    canvas.drawArc(
      rect,
      _startAngle,
      sweep,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.26 + 0.22 * pulse)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke + 8 + 4 * pulse
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // Busur nilai
    canvas.drawArc(
      rect,
      _startAngle,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round,
    );

    // Titik di ujung busur
    final end = _startAngle + sweep;
    final knob = Offset(
      center.dx + radius * math.cos(end),
      center.dy + radius * math.sin(end),
    );
    canvas.drawCircle(knob, 6, Paint()..color = Colors.white);
    canvas.drawCircle(knob, 3, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.value != value ||
      old.color != color ||
      old.max != max ||
      old.pulse != pulse;
}