import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

// Ambang batas disamakan dengan Dashboard.
const double _warnLimit = 25;
const double _dangerLimit = 50;

// Warna lokal (sama seperti Dashboard)
const Color _mutedLight = Color(0xFF9AB0A5);
const Color _track = Color(0xFFE6F0EA);

class _Status {
  final String label;
  final Color color;
  const _Status(this.label, this.color);
}

_Status _statusOf(double v) {
  if (v >= _dangerLimit) return const _Status('Bahaya', AppColors.danger);
  if (v >= _warnLimit) return const _Status('Waspada', AppColors.warning);
  return const _Status('Normal', AppColors.safe);
}

class _RangeData {
  final String name;
  final List<String> labels;
  final List<double> values;
  const _RangeData(this.name, this.labels, this.values);
}

// Data contoh — ganti dengan data dari sensor ESP32 / Blynk.
const _ranges = <_RangeData>[
  _RangeData(
    'Hari ini',
    ['00', '03', '06', '09', '12', '15', '18', '21'],
    [12, 15, 13, 18, 16, 22, 19, 14],
  ),
  _RangeData(
    '7 Hari',
    ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
    [14, 18, 16, 25, 20, 12, 17],
  ),
  _RangeData(
    '30 Hari',
    ['M1', 'M2', 'M3', 'M4', 'M5'],
    [15, 19, 17, 23, 16],
  ),
];

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  int _range = 0;
  int? _selected;

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
    final data = _ranges[_range];
    final values = data.values;
    final avg = values.reduce((a, b) => a + b) / values.length;
    final maxV = values.reduce(math.max);
    final minV = values.reduce(math.min);
    final status = _statusOf(avg);

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
                        _stagger(
                          0.10,
                          _RangeSelector(
                            selected: _range,
                            onChanged: (i) => setState(() {
                              _range = i;
                              _selected = null;
                            }),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _stagger(
                          0.20,
                          _ChartCard(
                            data: data,
                            average: avg,
                            status: status,
                            selected: _selected,
                            onSelect: (i) => setState(() => _selected = i),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _stagger(
                          0.32,
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.show_chart_rounded,
                                  color: AppColors.info,
                                  title: 'Rata-rata',
                                  value: avg.toStringAsFixed(1),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.arrow_upward_rounded,
                                  color: AppColors.danger,
                                  title: 'Tertinggi',
                                  value: maxV.toStringAsFixed(0),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _StatCard(
                                  icon: Icons.arrow_downward_rounded,
                                  color: AppColors.safe,
                                  title: 'Terendah',
                                  value: minV.toStringAsFixed(0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _stagger(0.42, _buildSectionTitle('Pembacaan Terakhir')),
                        const SizedBox(height: 10),
                        _stagger(0.48, _ReadingList(data: data)),
                        const SizedBox(height: 14),
                        const Center(
                          child: Text(
                            'Data contoh — belum terhubung ke sensor ESP32.',
                            style: TextStyle(color: _mutedLight, fontSize: 11.5),
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
                  'Riwayat & Grafik',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pantau tren kadar CO kabin',
                  style: TextStyle(
                    color: AppColors.onDarkMuted,
                    fontSize: 12,
                    letterSpacing: 0.3,
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
      child: Row(
        children: List.generate(_ranges.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: EdgeInsets.only(left: i == 0 ? 0 : 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(15),
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
                child: Text(
                  _ranges[i].name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : AppColors.textSecondary,
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

// ───────────────────────── Kartu grafik ─────────────────────────

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.data,
    required this.average,
    required this.status,
    required this.selected,
    required this.onSelect,
  });

  final _RangeData data;
  final double average;
  final _Status status;
  final int? selected;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.fromLTRB(18, 18, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: status.color.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kadar CO Rata-rata',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Sentuh grafik untuk melihat nilai',
                      style: TextStyle(color: _mutedLight, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          average.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 38,
                            height: 1.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 6),
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
                  ],
                ),
              ),
              _Pill(label: status.label, color: status.color),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 200,
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
          const SizedBox(height: 12),
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
  final int? selected;
  final Color color;

  static const double left = 30;
  static const double right = 8;
  static const double top = 14;
  static const double bottom = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width - left - right;
    final h = size.height - top - bottom;
    final n = values.length;

    final peak = math.max(values.reduce(math.max), _dangerLimit);
    final maxY = (peak * 1.15 / 20).ceil() * 20.0;

    double dx(int i) => left + (n == 1 ? w / 2 : w * i / (n - 1));
    double dy(double v) => top + h * (1 - v / maxY);

    // Grid + label sumbu Y
    final gridPaint = Paint()
      ..color = _track
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final v = maxY * i / 4;
      final y = dy(v);
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), gridPaint);
      _text(
        canvas,
        v.toStringAsFixed(0),
        Offset(left - 6, y),
        const TextStyle(fontSize: 10, color: _mutedLight),
        align: _Align.right,
      );
    }

    // Garis batas waspada & bahaya (putus-putus)
    _dashedLimit(canvas, size, dy(_warnLimit), AppColors.warning, 'Waspada');
    _dashedLimit(canvas, size, dy(_dangerLimit), AppColors.danger, 'Bahaya');

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
            color.withValues(alpha: 0.26),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(left, top, w, h)),
    );

    // Cahaya lembut di belakang kurva (seperti gauge Dashboard)
    canvas.drawPath(
      line,
      Paint()
        ..color = color.withValues(alpha: 0.26)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Titik kecil di tiap data
    for (final p in pts) {
      canvas.drawCircle(p, 3.5, Paint()..color = Colors.white);
      canvas.drawCircle(p, 2, Paint()..color = color);
    }

    // Label sumbu X
    for (var i = 0; i < n; i++) {
      _text(
        canvas,
        labels[i],
        Offset(dx(i), size.height - bottom + 8),
        TextStyle(
          fontSize: 10,
          color: i == selected ? AppColors.textPrimary : _mutedLight,
          fontWeight: i == selected ? FontWeight.w800 : FontWeight.w400,
        ),
        align: _Align.center,
      );
    }

    // Titik terpilih + tooltip
    final s = selected;
    if (s != null) {
      final p = pts[s];
      final sc = _statusOf(values[s]).color;
      canvas.drawLine(
        Offset(p.dx, top),
        Offset(p.dx, top + h),
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..strokeWidth = 1.2,
      );
      canvas.drawCircle(p, 9, Paint()..color = sc.withValues(alpha: 0.2));
      canvas.drawCircle(p, 7, Paint()..color = Colors.white);
      canvas.drawCircle(p, 4.5, Paint()..color = sc);

      final tp = TextPainter(
        text: TextSpan(
          text: '${values[s].toStringAsFixed(0)} ppm',
          style: const TextStyle(
            fontSize: 11.5,
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
      final by = math.max(p.dy - bh - 14, 0.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, by, bw, bh),
          const Radius.circular(10),
        ),
        Paint()..color = AppColors.darkMid,
      );
      tp.paint(canvas, Offset(bx + padX, by + padY));
    }
  }

  void _dashedLimit(
    Canvas canvas,
    Size size,
    double y,
    Color c,
    String label,
  ) {
    final dash = Paint()
      ..color = c.withValues(alpha: 0.8)
      ..strokeWidth = 1.2;
    for (double x = left; x < size.width - right; x += 8) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + 4, size.width - right), y),
        dash,
      );
    }
    _text(
      canvas,
      label,
      Offset(size.width - right - 2, y - 8),
      TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: c),
      align: _Align.right,
    );
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
  const _Pill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
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

// ───────────────────────── Kartu ringkasan ─────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;

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
          const SizedBox(height: 12),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 3),
              const Text(
                'ppm',
                style: TextStyle(color: _mutedLight, fontSize: 10.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Daftar pembacaan ─────────────────────────

class _ReadingList extends StatelessWidget {
  const _ReadingList({required this.data});

  final _RangeData data;

  @override
  Widget build(BuildContext context) {
    final count = math.min(4, data.values.length);

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
      child: Column(
        children: [
          for (var k = 0; k < count; k++) ...[
            if (k > 0) const Divider(height: 1, thickness: 1, color: _track),
            _ReadingRow(
              label: data.labels[data.values.length - 1 - k],
              value: data.values[data.values.length - 1 - k],
            ),
          ],
        ],
      ),
    );
  }
}

class _ReadingRow extends StatelessWidget {
  const _ReadingRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final s = _statusOf(value);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: s.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: s.color.withValues(alpha: 0.2)),
            ),
            child: Icon(Icons.air_rounded, color: s.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s.label,
                  style: TextStyle(
                    color: s.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)} ppm',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}