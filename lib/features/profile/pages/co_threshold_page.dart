import 'package:flutter/material.dart';

class _C {
  static const header = Color(0xFF0B3A3C);
  static const background = Color(0xFFF2F7F9);
  static const border = Color(0xFFE3EBEF);
  static const divider = Color(0xFFE9EFF2);
  static const title = Color(0xFF12292E);
  static const subtitle = Color(0xFF8A9AA1);
  static const body = Color(0xFF5B6B72);
  static const accent = Color(0xFF2DBE75);
}

class CoThresholdPage extends StatefulWidget {
  const CoThresholdPage({super.key, this.initialValue = 25});

  final double initialValue;

  @override
  State<CoThresholdPage> createState() => _CoThresholdPageState();
}

class _CoThresholdPageState extends State<CoThresholdPage> {
  static const _min = 10.0;
  static const _max = 50.0;
  static const _presets = <String, double>{
    'Sensitif': 15,
    'Standar': 25,
    'Toleran': 35,
  };

  late double _value = widget.initialValue;

  String get _level {
    if (_value <= 20) return 'Sangat sensitif';
    if (_value <= 30) return 'Standar';
    return 'Toleran';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.header,
      appBar: AppBar(
        backgroundColor: _C.header,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        toolbarHeight: 72,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ambang Batas CO',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Atur batas aman gas CO',
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withAlpha(165),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: _C.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _C.border),
                boxShadow: [
                  BoxShadow(
                    color: _C.header.withAlpha(12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _value.round().toString(),
                        style: const TextStyle(
                          fontSize: 64,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2,
                          color: _C.title,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'ppm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _C.subtitle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: _C.accent.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _level,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F9D77),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 5,
                      activeTrackColor: _C.accent,
                      inactiveTrackColor: _C.divider,
                      thumbColor: _C.accent,
                      overlayColor: _C.accent.withAlpha(30),
                    ),
                    child: Slider(
                      value: _value,
                      min: _min,
                      max: _max,
                      divisions: (_max - _min).round(),
                      onChanged: (v) => setState(() => _value = v),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('10',
                            style:
                                TextStyle(fontSize: 12, color: _C.subtitle)),
                        Text('50',
                            style:
                                TextStyle(fontSize: 12, color: _C.subtitle)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                for (final e in _presets.entries) ...[
                  Expanded(
                    child: _PresetChip(
                      label: e.key,
                      value: e.value,
                      active: _value == e.value,
                      onTap: () => setState(() => _value = e.value),
                    ),
                  ),
                  if (e.key != _presets.keys.last) const SizedBox(width: 10),
                ],
              ],
            ),
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Peringatan akan berbunyi saat kadar CO di kabin melebihi '
                'nilai ini.',
                style: TextStyle(fontSize: 13, height: 1.5, color: _C.body),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: () {
                  // TODO: kirim nilai ke ESP32 / Blynk & simpan lokal.
                  Navigator.pop(context, _value);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: _C.header,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.value,
    required this.active,
    required this.onTap,
  });

  final String label;
  final double value;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? _C.header : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? _C.header : _C.border),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : _C.title,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${value.round()} ppm',
              style: TextStyle(
                fontSize: 11.5,
                color: active ? Colors.white70 : _C.subtitle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}