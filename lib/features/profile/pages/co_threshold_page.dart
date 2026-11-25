import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

const Color _track = Color(0xFFE6F0EA);

// Rentang pengaturan
const double _warnMin = 10;
const double _warnMax = 50;
const double _dangerMin = 15; // = batas Waspada terendah + jarak minimal
const double _dangerMax = 90;
const double _gap = 5; // batas Bahaya minimal berjarak 5 ppm di atas Waspada
const double _batteryMin = 10;
const double _batteryMax = 13;

class _Preset {
  const _Preset(this.name, this.warn, this.danger);
  final String name;
  final double warn;
  final double danger;
}

const _presets = <_Preset>[
  _Preset('Sensitif', 15, 35),
  _Preset('Standar', 25, 50),
  _Preset('Toleran', 35, 70),
];

class CoThresholdPage extends StatefulWidget {
  const CoThresholdPage({
    super.key,
    this.initialValue = 25, // batas Waspada (ppm)
    this.initialDanger = 50, // batas Bahaya (ppm)
    this.initialBattery = 11.5, // batas baterai rendah (V)
  });

  final double initialValue;
  final double initialDanger;
  final double initialBattery;

  @override
  State<CoThresholdPage> createState() => _CoThresholdPageState();
}

class _CoThresholdPageState extends State<CoThresholdPage> {
  late double _warn =
      widget.initialValue.clamp(_warnMin, _warnMax).toDouble();
  late double _danger =
      widget.initialDanger.clamp(_warn + _gap, _dangerMax).toDouble();
  late double _battery =
      widget.initialBattery.clamp(_batteryMin, _batteryMax).toDouble();

  bool _saving = false;

  // Batas Bahaya selalu dijaga lebih tinggi dari batas Waspada,
  // jadi pengguna tidak perlu melihat pesan error.
  void _setWarn(double v) {
    setState(() {
      _warn = v;
      if (_danger < v + _gap) _danger = v + _gap;
    });
  }

  void _setDanger(double v) {
    setState(() => _danger = v < _warn + _gap ? _warn + _gap : v);
  }

  void _applyPreset(_Preset p) {
    setState(() {
      _warn = p.warn;
      _danger = p.danger;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      // TODO: kirim batas Waspada, Bahaya, dan baterai ke ESP32 / Firebase
      // dan simpan juga di ponsel.
      await Future<void>.delayed(const Duration(seconds: 1))
          .timeout(const Duration(seconds: 5));
      if (!mounted) return;
      _showMessage('Batas berhasil disimpan');
      Navigator.pop(context, _warn);
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('Perangkat tidak merespons. Coba lagi.', error: true);
    }
  }

  void _showMessage(String message, {bool error = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? AppColors.danger : AppColors.darkMid,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = _warn.round();
    final d = _danger.round();

    return Scaffold(
      backgroundColor: AppColors.darkMid,
      appBar: AppBar(
        backgroundColor: AppColors.darkMid,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        toolbarHeight: 72,
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Batas kadar CO',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Tentukan kapan peringatan muncul',
              style: TextStyle(fontSize: 13, color: AppColors.onDarkMuted),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            // ───────── Ringkasan zona ─────────
            _ZoneSummary(warn: _warn, danger: _danger),

            // ───────── Pilih cepat ─────────
            const SizedBox(height: 22),
            const _SectionTitle('Pilih cepat'),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < _presets.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _PresetChip(
                      preset: _presets[i],
                      active: _warn == _presets[i].warn &&
                          _danger == _presets[i].danger,
                      onTap: () => _applyPreset(_presets[i]),
                    ),
                  ),
                ],
              ],
            ),

            // ───────── Atur manual ─────────
            const SizedBox(height: 22),
            const _SectionTitle('Atur manual'),
            const SizedBox(height: 10),
            _LimitCard(
              title: 'Batas Waspada',
              hint: 'Peringatan muncul di aplikasi saat kadar CO mencapai '
                  'angka ini.',
              valueText: '$w ppm',
              color: AppColors.warning,
              value: _warn,
              min: _warnMin,
              max: _warnMax,
              divisions: (_warnMax - _warnMin).round(),
              minText: '${_warnMin.round()}',
              maxText: '${_warnMax.round()}',
              onChanged: _setWarn,
            ),
            const SizedBox(height: 12),
            _LimitCard(
              title: 'Batas Bahaya',
              hint: 'Buzzer menyala otomatis dan peringatan dikirim ke '
                  'aplikasi. Selalu lebih tinggi dari batas Waspada.',
              valueText: '$d ppm',
              color: AppColors.danger,
              value: _danger,
              min: _dangerMin,
              max: _dangerMax,
              divisions: (_dangerMax - _dangerMin).round(),
              minText: '${_dangerMin.round()}',
              maxText: '${_dangerMax.round()}',
              onChanged: _setDanger,
            ),

            // ───────── Baterai ─────────
            const SizedBox(height: 22),
            const _SectionTitle('Baterai perangkat'),
            const SizedBox(height: 10),
            _LimitCard(
              title: 'Batas baterai rendah',
              hint: 'Status "Baterai rendah" muncul saat tegangan di bawah '
                  'angka ini.',
              valueText: '${_battery.toStringAsFixed(1)} V',
              color: AppColors.info,
              value: _battery,
              min: _batteryMin,
              max: _batteryMax,
              divisions: ((_batteryMax - _batteryMin) * 10).round(),
              minText: '${_batteryMin.toStringAsFixed(1)} V',
              maxText: '${_batteryMax.toStringAsFixed(1)} V',
              onChanged: (v) => setState(() => _battery = v),
            ),

            const SizedBox(height: 26),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Komponen ─────────────────────────

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

BoxDecoration _cardDecoration() {
  return BoxDecoration(
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
  );
}

/// Bar tiga warna + penjelasan arti tiap zona, berubah mengikuti pengaturan.
class _ZoneSummary extends StatelessWidget {
  const _ZoneSummary({required this.warn, required this.danger});

  final double warn;
  final double danger;

  @override
  Widget build(BuildContext context) {
    final w = warn.round();
    final d = danger.round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengaturan saat ini',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  Expanded(
                    flex: (warn * 10).round(),
                    child: const ColoredBox(color: AppColors.safe),
                  ),
                  Expanded(
                    flex: ((danger - warn) * 10).round(),
                    child: const ColoredBox(color: AppColors.warning),
                  ),
                  Expanded(
                    flex: ((100 - danger) * 10).round(),
                    child: const ColoredBox(color: AppColors.danger),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              Text('100 ppm',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 14),
          _ZoneRow(
            color: AppColors.safe,
            icon: Icons.check_circle_rounded,
            label: 'Normal',
            range: 'Di bawah $w ppm',
            meaning: 'Udara aman.',
          ),
          const SizedBox(height: 10),
          _ZoneRow(
            color: AppColors.warning,
            icon: Icons.warning_amber_rounded,
            label: 'Waspada',
            range: '$w sampai ${d - 1} ppm',
            meaning: 'Peringatan muncul di aplikasi.',
          ),
          const SizedBox(height: 10),
          _ZoneRow(
            color: AppColors.danger,
            icon: Icons.dangerous_rounded,
            label: 'Bahaya',
            range: '$d ppm ke atas',
            meaning: 'Buzzer menyala dan peringatan dikirim.',
          ),
        ],
      ),
    );
  }
}

class _ZoneRow extends StatelessWidget {
  const _ZoneRow({
    required this.color,
    required this.icon,
    required this.label,
    required this.range,
    required this.meaning,
  });

  final Color color;
  final IconData icon;
  final String label;
  final String range;
  final String meaning;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: '  $range',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 14.5),
              ),
              const SizedBox(height: 1),
              Text(
                meaning,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.preset,
    required this.active,
    required this.onTap,
  });

  final _Preset preset;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      excludeSemantics: true,
      label: '${preset.name}, Waspada ${preset.warn.round()} ppm, '
          'Bahaya ${preset.danger.round()} ppm',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                preset.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${preset.warn.round()} / ${preset.danger.round()} ppm',
                style: TextStyle(
                  fontSize: 12,
                  color: active ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LimitCard extends StatelessWidget {
  const _LimitCard({
    required this.title,
    required this.hint,
    required this.valueText,
    required this.color,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.minText,
    required this.maxText,
    required this.onChanged,
  });

  final String title;
  final String hint;
  final String valueText;
  final Color color;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String minText;
  final String maxText;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                valueText,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            hint,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: color,
              inactiveTrackColor: _track,
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.14),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: valueText,
              semanticFormatterCallback: (_) => '$title $valueText',
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  maxText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}