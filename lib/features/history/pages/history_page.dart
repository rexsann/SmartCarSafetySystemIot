import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

// Ambang batas disamakan dengan Dashboard.
const double _warnLimit = 25;
const double _dangerLimit = 50;

const Color _track = Color(0xFFE6F0EA);

// ───────────────────────── Status ─────────────────────────

class _Status {
  final String label;
  final String headline;
  final String advice;
  final Color color;
  final IconData icon;
  const _Status({
    required this.label,
    required this.headline,
    required this.advice,
    required this.color,
    required this.icon,
  });
}

_Status _statusOf(double v) {
  if (v >= _dangerLimit) {
    return const _Status(
      label: 'Bahaya',
      headline: 'Kadar CO berbahaya',
      advice: 'Segera hentikan kendaraan di tempat aman, buka semua jendela, '
          'dan keluar dari kabin.',
      color: AppColors.danger,
      icon: Icons.dangerous_rounded,
    );
  }
  if (v >= _warnLimit) {
    return const _Status(
      label: 'Waspada',
      headline: 'Kadar CO mulai tinggi',
      advice: 'Buka jendela atau nyalakan sirkulasi udara luar, '
          'lalu terus pantau kadar CO.',
      color: AppColors.warning,
      icon: Icons.warning_amber_rounded,
    );
  }
  return const _Status(
    label: 'Normal',
    headline: 'Udara kabin aman',
    advice: 'Kadar CO di bawah batas waspada. Tidak perlu tindakan.',
    color: AppColors.safe,
    icon: Icons.check_circle_rounded,
  );
}

// ───────────────────────── Data ─────────────────────────

class _RangeData {
  final String name;
  final String period;
  final List<String> labels; // label pendek untuk sumbu X
  final List<String> details; // label lengkap untuk detail & daftar
  final List<double> values;
  const _RangeData({
    required this.name,
    required this.period,
    required this.labels,
    required this.details,
    required this.values,
  });
}

// Data contoh — ganti dengan data dari sensor ESP32 / Firebase.
const _ranges = <_RangeData>[
  _RangeData(
    name: 'Hari ini',
    period: 'Hari ini, setiap 3 jam',
    labels: ['00:00', '03:00', '06:00', '09:00', '12:00', '15:00', '18:00', '21:00'],
    details: [
      'Pukul 00:00',
      'Pukul 03:00',
      'Pukul 06:00',
      'Pukul 09:00',
      'Pukul 12:00',
      'Pukul 15:00',
      'Pukul 18:00',
      'Pukul 21:00',
    ],
    values: [12, 15, 13, 18, 16, 22, 19, 14],
  ),
  _RangeData(
    name: '7 Hari',
    period: '7 hari terakhir',
    labels: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
    details: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'],
    values: [14, 18, 16, 25, 20, 12, 17],
  ),
  _RangeData(
    name: '30 Hari',
    period: '30 hari terakhir, per minggu',
    labels: ['M1', 'M2', 'M3', 'M4', 'M5'],
    details: [
      'Minggu ke-1',
      'Minggu ke-2',
      'Minggu ke-3',
      'Minggu ke-4',
      'Minggu ke-5',
    ],
    values: [15, 19, 17, 23, 16],
  ),
];

BoxDecoration _cardDecoration({double radius = 22, Color? glow}) {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.border),
    boxShadow: [
      BoxShadow(
        color: (glow ?? AppColors.primaryDark).withValues(alpha: 0.06),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

// ───────────────────────── Halaman ─────────────────────────

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  int _range = 0;
  int? _selected; // null = pembacaan terbaru

  late final AnimationController _enter;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    super.dispose();
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
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _ranges[_range];
    final values = data.values;
    final n = values.length;
    final avg = values.reduce((a, b) => a + b) / n;
    final maxV = values.reduce(math.max);
    final minV = values.reduce(math.min);
    final maxI = values.indexOf(maxV);
    final minI = values.indexOf(minV);
    final status = _statusOf(avg);
    final sel = _selected ?? n - 1;

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
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                    child: Container(
                      width: double.infinity,
                      color: AppColors.background,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                        children: [
                          _stagger(
                            0.08,
                            _RangeSelector(
                              selected: _range,
                              onChanged: (i) => setState(() {
                                _range = i;
                                _selected = null;
                              }),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _stagger(0.14, const _SampleBanner()),
                          const SizedBox(height: 14),
                          _stagger(
                            0.20,
                            _SummaryCard(
                              status: status,
                              average: avg,
                              period: data.period,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _stagger(
                            0.28,
                            _ChartCard(
                              data: data,
                              selected: sel,
                              onSelect: (i) => setState(() => _selected = i),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _stagger(
                            0.36,
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: _StatCard(
                                      icon: Icons.show_chart_rounded,
                                      color: AppColors.info,
                                      title: 'Rata-rata',
                                      value: avg.toStringAsFixed(1),
                                      caption: '$n pembacaan',
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _StatCard(
                                      icon: Icons.arrow_upward_rounded,
                                      color: AppColors.danger,
                                      title: 'Tertinggi',
                                      value: maxV.toStringAsFixed(0),
                                      caption: data.details[maxI],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _StatCard(
                                      icon: Icons.arrow_downward_rounded,
                                      color: AppColors.safe,
                                      title: 'Terendah',
                                      value: minV.toStringAsFixed(0),
                                      caption: data.details[minI],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _stagger(0.42, _buildSectionTitle('Arti status')),
                          const SizedBox(height: 10),
                          _stagger(0.46, const _StatusGuide()),
                          const SizedBox(height: 22),
                          _stagger(
                              0.50, _buildSectionTitle('Riwayat pembacaan')),
                          const SizedBox(height: 4),
                          const Padding(
                            padding: EdgeInsets.only(left: 11, bottom: 10),
                            child: Text(
                              'Terbaru di atas. Bar menunjukkan seberapa dekat '
                              'dengan batas bahaya (50 ppm).',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                                height: 1.35,
                              ),
                            ),
                          ),
                          _stagger(
                            0.54,
                            _ReadingList(
                              data: data,
                              selected: sel,
                              onSelect: (i) => setState(() => _selected = i),
                            ),
                          ),
                        ],
                      ),
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
              Icons.insights_rounded,
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
                  'Riwayat & grafik',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Lihat perubahan kadar CO di kabin',
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

  Widget _buildSectionTitle(String text) {
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

// ───────────────────────── Pemilih rentang ─────────────────────────

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: _cardDecoration(radius: 20),
      child: Row(
        children: List.generate(_ranges.length, (i) {
          final active = i == selected;
          return Expanded(
            child: Semantics(
              button: true,
              selected: active,
              label: 'Tampilkan ${_ranges[i].name}',
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  constraints: const BoxConstraints(minHeight: 48),
                  margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    _ranges[i].name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ───────────────────────── Banner data contoh ─────────────────────────

class _SampleBanner extends StatelessWidget {
  const _SampleBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.22)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.info, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ini data contoh. Grafik belum terhubung ke sensor ESP32.',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Ringkasan kondisi ─────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.status,
    required this.average,
    required this.period,
  });

  final _Status status;
  final double average;
  final String period;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: 'Rata-rata ${average.toStringAsFixed(1)} ppm. '
          '${status.headline}. ${status.advice}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: status.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: status.color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(status.icon, color: status.color, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rata-rata • $period',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        status.headline,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: average.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 40,
                          height: 1.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      const TextSpan(
                        text: '  ppm',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                _Pill(status: status),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: status.color, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      status.advice,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Kartu grafik ─────────────────────────

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.data,
    required this.selected,
    required this.onSelect,
  });

  final _RangeData data;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final isLatest = selected == data.values.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 12, 16),
      decoration: _cardDecoration(radius: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Text(
              'Tren kadar CO',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          const Padding(
            padding: EdgeInsets.only(left: 2),
            child: Text(
              'Ketuk atau geser pada grafik untuk melihat detail.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
            ),
          ),
          const SizedBox(height: 14),
          Semantics(
            label: 'Grafik kadar CO ${data.period}. '
                'Nilai terpilih ${data.details[selected]}: '
                '${data.values[selected].toStringAsFixed(0)} ppm.',
            child: SizedBox(
              height: 220,
              child: LayoutBuilder(
                builder: (context, c) {
                  void pick(Offset p) {
                    const left = _LineChartPainter.left;
                    const right = _LineChartPainter.right;
                    final w = c.maxWidth - left - right;
                    final n = data.values.length;
                    final i = (((p.dx - left) / w) * (n - 1))
                        .round()
                        .clamp(0, n - 1);
                    onSelect(i);
                  }

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => pick(d.localPosition),
                    onHorizontalDragUpdate: (d) => pick(d.localPosition),
                    child: CustomPaint(
                      size: Size(c.maxWidth, c.maxHeight),
                      painter: _LineChartPainter(
                        values: data.values,
                        labels: data.labels,
                        selected: selected,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SelectedDetail(
            title: data.details[selected],
            value: data.values[selected],
            isLatest: isLatest,
          ),
        ],
      ),
    );
  }
}

class _SelectedDetail extends StatelessWidget {
  const _SelectedDetail({
    required this.title,
    required this.value,
    required this.isLatest,
  });

  final String title;
  final double value;
  final bool isLatest;

  @override
  Widget build(BuildContext context) {
    final s = _statusOf(value);
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '$title, ${value.toStringAsFixed(0)} ppm, status ${s.label}',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: s.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: s.color.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLatest ? '$title (terbaru)' : title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _Pill(status: s),
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value.toStringAsFixed(0),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(
                    text: ' ppm',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.values,
    required this.labels,
    required this.selected,
    required this.color,
  });

  final List<double> values;
  final List<String> labels;
  final int selected;
  final Color color;

  static const double left = 36;
  static const double right = 10;
  static const double top = 16;
  static const double bottom = 28;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width - left - right;
    final h = size.height - top - bottom;
    final n = values.length;

    final peak = values.reduce(math.max);
    final maxY = math.max(60.0, (peak * 1.15 / 10).ceil() * 10.0);

    double dx(int i) => left + (n == 1 ? w / 2 : w * i / (n - 1));
    double dy(double v) => top + h * (1 - v / maxY);

    // Zona warna: normal / waspada / bahaya
    void zone(double from, double to, Color c) {
      canvas.drawRect(
        Rect.fromLTRB(left, dy(math.min(to, maxY)), left + w, dy(from)),
        Paint()..color = c.withValues(alpha: 0.09),
      );
    }

    zone(0, _warnLimit, AppColors.safe);
    zone(_warnLimit, _dangerLimit, AppColors.warning);
    zone(_dangerLimit, maxY, AppColors.danger);

    // Grid + label sumbu Y (kelipatan 25, termasuk kedua batas)
    final gridPaint = Paint()
      ..color = _track
      ..strokeWidth = 1;
    for (double v = 0; v <= maxY; v += 25) {
      final y = dy(v);
      canvas.drawLine(Offset(left, y), Offset(left + w, y), gridPaint);
      _text(
        canvas,
        v.toStringAsFixed(0),
        Offset(left - 6, y),
        const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        align: _Align.right,
      );
    }
    _text(
      canvas,
      'ppm',
      Offset(left - 6, 4),
      const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
      align: _Align.right,
    );

    // Kurva halus
    final pts = [for (var i = 0; i < n; i++) Offset(dx(i), dy(values[i]))];
    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < n - 1; i++) {
      final a = pts[i];
      final b = pts[i + 1];
      final midX = (a.dx + b.dx) / 2;
      line.cubicTo(midX, a.dy, midX, b.dy, b.dx, b.dy);
    }

    // Area gradien di bawah kurva
    final fill = Path.from(line)
      ..lineTo(pts.last.dx, top + h)
      ..lineTo(pts.first.dx, top + h)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(left, top, w, h)),
    );

    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Titik data berwarna sesuai status
    for (var i = 0; i < n; i++) {
      final c = _statusOf(values[i]).color;
      canvas.drawCircle(pts[i], 5, Paint()..color = Colors.white);
      canvas.drawCircle(pts[i], 3.5, Paint()..color = c);
    }

    // Label sumbu X
    for (var i = 0; i < n; i++) {
      final active = i == selected;
      _text(
        canvas,
        labels[i],
        Offset(dx(i), size.height - bottom + 12),
        TextStyle(
          fontSize: 11,
          color: active ? AppColors.textPrimary : AppColors.textSecondary,
          fontWeight: active ? FontWeight.w800 : FontWeight.w400,
        ),
        align: _Align.center,
      );
    }

    // Titik terpilih + gelembung nilai
    final p = pts[selected];
    final sc = _statusOf(values[selected]).color;
    canvas.drawLine(
      Offset(p.dx, top),
      Offset(p.dx, top + h),
      Paint()
        ..color = color.withValues(alpha: 0.4)
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(p, 11, Paint()..color = sc.withValues(alpha: 0.22));
    canvas.drawCircle(p, 8, Paint()..color = Colors.white);
    canvas.drawCircle(p, 5.5, Paint()..color = sc);

    final tp = TextPainter(
      text: TextSpan(
        text: '${values[selected].toStringAsFixed(0)} ppm',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    const padX = 10.0;
    const padY = 6.0;
    final bw = tp.width + padX * 2;
    final bh = tp.height + padY * 2;
    final bx = (p.dx - bw / 2).clamp(left, size.width - right - bw);
    final by = math.max(p.dy - bh - 16, 0.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx, by, bw, bh),
        const Radius.circular(10),
      ),
      Paint()..color = AppColors.darkMid,
    );
    tp.paint(canvas, Offset(bx + padX, by + padY));
  }

  void _text(
    Canvas canvas,
    String text,
    Offset at,
    TextStyle style, {
    required _Align align,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = switch (align) {
      _Align.left => at.dx,
      _Align.center => at.dx - tp.width / 2,
      _Align.right => at.dx - tp.width,
    };
    tp.paint(canvas, Offset(x, at.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.values != values || old.selected != selected || old.color != color;
}

enum _Align { left, center, right }

// ───────────────────────── Widget kecil ─────────────────────────

class _Pill extends StatelessWidget {
  const _Pill({required this.status});

  final _Status status;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: status.color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, color: status.color, size: 15),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              color: status.color,
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Kartu ringkasan angka ─────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.caption,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(radius: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const TextSpan(
                  text: ' ppm',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Panduan arti status ─────────────────────────

class _StatusGuide extends StatelessWidget {
  const _StatusGuide();

  @override
  Widget build(BuildContext context) {
    final items = <(_Status, String, String)>[
      (_statusOf(0), 'Di bawah 25 ppm', 'Udara aman, tidak perlu tindakan.'),
      (
        _statusOf(_warnLimit),
        '25 sampai 49 ppm',
        'Mulai tinggi. Buka ventilasi dan terus pantau.'
      ),
      (
        _statusOf(_dangerLimit),
        '50 ppm ke atas',
        'Berbahaya. Segera keluar dan cari udara segar.'
      ),
    ];

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          for (var k = 0; k < items.length; k++) ...[
            if (k > 0) const Divider(height: 1, thickness: 1, color: _track),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: items[k].$1.color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      items[k].$1.icon,
                      color: items[k].$1.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: items[k].$1.label,
                                style: TextStyle(
                                  color: items[k].$1.color,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: '  ${items[k].$2}',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[k].$3,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────── Daftar pembacaan ─────────────────────────

class _ReadingList extends StatelessWidget {
  const _ReadingList({
    required this.data,
    required this.selected,
    required this.onSelect,
  });

  final _RangeData data;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final n = data.values.length;

    return Container(
      decoration: _cardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: [
            for (var k = 0; k < n; k++) ...[
              if (k > 0) const Divider(height: 1, thickness: 1, color: _track),
              _ReadingRow(
                label: data.details[n - 1 - k],
                value: data.values[n - 1 - k],
                isLatest: k == 0,
                isSelected: (n - 1 - k) == selected,
                onTap: () => onSelect(n - 1 - k),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReadingRow extends StatelessWidget {
  const _ReadingRow({
    required this.label,
    required this.value,
    required this.isLatest,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final double value;
  final bool isLatest;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = _statusOf(value);
    return Semantics(
      button: true,
      selected: isSelected,
      excludeSemantics: true,
      label: '$label, ${value.toStringAsFixed(0)} ppm, status ${s.label}',
      child: Material(
        color: isSelected ? s.color.withValues(alpha: 0.08) : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: s.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: s.color.withValues(alpha: 0.2)),
                  ),
                  child: Icon(s.icon, color: s.color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isLatest ? '$label (terbaru)' : label,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.label,
                        style: TextStyle(
                          color: s.color,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (value / _dangerLimit).clamp(0.0, 1.0),
                          minHeight: 5,
                          backgroundColor: _track,
                          valueColor: AlwaysStoppedAnimation<Color>(s.color),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  '${value.toStringAsFixed(0)} ppm',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}