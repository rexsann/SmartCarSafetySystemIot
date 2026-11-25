import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../notifications/pages/notifications_page.dart';

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
  bool buzzerEnabled = false;

  // State perangkat (Bab 4)
  bool sensorError = false;
  double batteryVolt = 12.4;

  // State UI
  bool _loading = true; // skeleton saat data pertama dimuat
  bool _buzzerBusy = false; // loading toggle buzzer (maks 5 detik)
  bool _dangerSeen = false; // modal/buzzer sudah dipicu pada episode bahaya ini
  bool _modalOpen = false;
  Timer? _poll;

  // Set false untuk menyembunyikan kartu simulasi saat produksi.
  static const bool _showSimulator = true;

  static const double _maxPpm = 200;
  static const double _warnLevel = 25; // batas Waspada (ppm)
  static const double _dangerLevel = 50; // batas Bahaya (ppm)
  static const double _lowBattery = 11.5; // batas baterai rendah (V)

  // Warna lokal yang hanya dipakai di halaman ini
  static const Color _mutedLight = Color(0xFF9AB0A5);
  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _goldDeep = Color(0xFFB8963E);
  static const Color _orange = Color(0xFFF97316);
  static const Color _noData = Color(0xFF9AA5A0);

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

    // Skeleton singkat saat data pertama dimuat.
    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _loading = false);
      _evaluate();
    });

    // Perbarui data setiap 5 detik.
    _poll = Timer.periodic(const Duration(seconds: 5), (_) => _fetchData());
  }

  @override
  void dispose() {
    _poll?.cancel();
    _enter.dispose();
    _pulse.dispose();
    super.dispose();
  }

  // ───────────────────────── Logika ─────────────────────────

  // Ada data valid hanya jika ESP32 online dan sensor tidak error.
  bool get hasData => espConnected && !sensorError;

  // LED mengikuti kondisi CO (Aman / Waspada / Bahaya).
  bool get ledActive => hasData && coLevel >= _warnLevel;

  bool get _isDanger => hasData && coLevel >= _dangerLevel;

  void _fetchData() {
    // TODO: ambil data terbaru dari ESP32 / Blynk, isi coLevel,
    // batteryVolt, sensorError, espConnected, lalu panggil _evaluate().
    // Jika tidak ada data > 15 detik, set espConnected = false.
  }

  // Buzzer menyala otomatis & modal muncul sekali saat masuk zona Bahaya.
  void _evaluate() {
    if (_isDanger) {
      if (!_dangerSeen) {
        _dangerSeen = true;
        buzzerEnabled = true;
        // TODO: kirim push notification "Kadar CO meningkat".
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _showWarningModal();
          _showToast('Bahaya! Buzzer menyala otomatis', error: true);
        });
      }
    } else if (hasData) {
      _dangerSeen = false; // CO kembali aman → siap memicu lagi
    }
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
  }

  String? get _buzzerDisabledMessage {
    if (!espConnected) return 'Perangkat offline, perintah tidak dapat dikirim';
    if (!buzzerEnabled) return 'Buzzer hanya menyala otomatis saat bahaya';
    if (_isDanger) {
      return 'Kadar CO masih berbahaya, buzzer tidak dapat dimatikan';
    }
    return null;
  }

  Future<void> _onBuzzerToggle() async {
    if (_buzzerBusy) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Matikan buzzer?'),
        content: const Text('Kadar CO sudah kembali aman.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Matikan'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _buzzerBusy = true);
    try {
      // TODO: kirim perintah matikan buzzer ke ESP32.
      await Future<void>.delayed(const Duration(seconds: 1))
          .timeout(const Duration(seconds: 5));
      if (!mounted) return;
      setState(() {
        buzzerEnabled = false;
        _buzzerBusy = false;
      });
      _showToast('Buzzer dimatikan');
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _buzzerBusy = false);
      _showToast('Perangkat tidak merespons, buzzer tetap ON', error: true);
    }
  }

  Future<void> _showWarningModal() async {
    if (!mounted || _modalOpen) return;
    _modalOpen = true;
    final now = TimeOfDay.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    Widget row(String l, String v, {Color? color}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(l,
                  style: const TextStyle(color: Colors.white60, fontSize: 12.5)),
              const Spacer(),
              Text(v,
                  style: TextStyle(
                    color: color ?? Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        );

    final detail = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF2A1518),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.danger.withValues(alpha: 0.18),
                ),
                child: const Icon(Icons.warning_rounded,
                    color: AppColors.danger, size: 30),
              ),
              const SizedBox(height: 12),
              const Text('Peringatan!',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text('Kadar CO Terdeteksi Tinggi',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Kadar CO',
                            style: TextStyle(
                                color: Colors.white60, fontSize: 12.5)),
                        const Spacer(),
                        Text('${coLevel.round()} ppm',
                            style: const TextStyle(
                                color: AppColors.danger,
                                fontSize: 22,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    row('Status Kabin', 'Kondisi tidak aman',
                        color: AppColors.danger),
                    row('Waktu', time),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Lihat Detail',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Tutup',
                    style: TextStyle(color: Colors.white60)),
              ),
            ],
          ),
        ),
      ),
    );
    _modalOpen = false;
    if (detail == true && mounted) {
      _openNotifications();
    }
  }

  // Toast 3 detik di pojok kanan atas.
  void _showToast(String message, {bool error = false}) {
    if (!mounted) return;
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: MediaQuery.of(ctx).padding.top + 12,
        right: 16,
        child: _Toast(message: message, error: error),
      ),
    );
    overlay.insert(entry);
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) entry.remove();
    });
  }

  _Condition get condition {
    if (!hasData) {
      return _Condition(
        label: espConnected ? 'Error' : 'Offline',
        title: 'Data tidak tersedia',
        message: espConnected
            ? 'Sensor CO tidak terbaca. Periksa sensor.'
            : 'ESP32 terputus. Periksa koneksi perangkat.',
        color: _noData,
        icon: espConnected
            ? Icons.sensors_off_rounded
            : Icons.cloud_off_rounded,
      );
    }
    if (coLevel >= _dangerLevel) {
      return const _Condition(
        label: 'Bahaya',
        title: 'Bahaya CO!',
        message: 'Kadar CO sangat tinggi. Buka jendela dan keluar dari mobil.',
        color: AppColors.danger,
        icon: Icons.warning_rounded,
        isDanger: true,
      );
    }
    if (coLevel >= _warnLevel) {
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
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                    child: Container(
                      width: double.infinity,
                      color: AppColors.background,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                        children: [
                          _stagger(
                            0.15,
                            _loading
                                ? const _SkeletonBox(height: 420, radius: 26)
                                : _buildGaugeCard(c),
                          ),
                          const SizedBox(height: 14),
                          _stagger(
                              0.30, _buildSectionTitle('Status Perangkat')),
                          const SizedBox(height: 10),
                          _buildDeviceGrid(),
                          if (_showSimulator) ...[
                            const SizedBox(height: 18),
                            _buildSimulator(),
                          ],
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
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 22),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
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
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.jpg',
                fit: BoxFit.cover,
                cacheWidth: 156,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GasGuard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Smart Car Safety System',
                  style: TextStyle(
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
              onPressed: _openNotifications,
              tooltip: 'Notifikasi',
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                  if (_isDanger)
                    Positioned(
                      top: -1,
                      right: -1,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.darkMid, width: 1.2),
                        ),
                      ),
                    ),
                ],
              ),
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
              // Tanpa data → jarum diam di 0.
              tween: Tween(begin: 0, end: hasData ? coLevel : 0),
              duration: const Duration(milliseconds: 300),
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
                                ? 0.5 +
                                    0.5 * math.sin(_pulse.value * 2 * math.pi)
                                : 0,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasData ? v.toStringAsFixed(0) : '--',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LegendItem(
                  color: AppColors.safe,
                  label: 'Normal  < ${_warnLevel.round()}'),
              _LegendItem(
                  color: AppColors.warning,
                  label:
                      'Waspada  ${_warnLevel.round()}-${_dangerLevel.round()}'),
              _LegendItem(
                  color: AppColors.danger,
                  label: 'Bahaya  > ${_dangerLevel.round()}'),
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
    if (_loading) {
      return GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(4, (_) => const _SkeletonBox(radius: 20)),
      );
    }

    final lowBattery = batteryVolt < _lowBattery;
    final ledLabel = !hasData
        ? 'Tidak diketahui'
        : coLevel >= _dangerLevel
            ? 'Bahaya'
            : coLevel >= _warnLevel
                ? 'Waspada'
                : 'Aman';
    final ledColor = !hasData
        ? _noData
        : coLevel >= _dangerLevel
            ? AppColors.danger
            : coLevel >= _warnLevel
                ? AppColors.warning
                : AppColors.safe;

    final disabledMsg = _buzzerDisabledMessage;
    final canToggle = disabledMsg == null && !_buzzerBusy;

    final tiles = <Widget>[
      _DeviceTile(
        icon: Icons.wifi_rounded,
        color: AppColors.info,
        title: 'Koneksi ESP32',
        value: espConnected ? 'Online' : 'Offline',
        valueColor: espConnected ? AppColors.online : AppColors.offline,
        onTap: () {
          // TODO: buka detail koneksi ESP32.
        },
      ),
      _DeviceTile(
        icon: lowBattery
            ? Icons.battery_alert_rounded
            : Icons.battery_5_bar_rounded,
        color: lowBattery ? _orange : _purple,
        title: 'Baterai',
        value: '${batteryVolt.toStringAsFixed(1)} V',
        valueColor: lowBattery ? _orange : null,
        onTap: () {
          // TODO: buka detail baterai.
        },
      ),
      _DeviceTile(
        icon: Icons.lightbulb_outline_rounded,
        color: _goldDeep,
        title: 'Status LED',
        value: ledLabel,
        valueColor: ledColor,
        onTap: () {
          // TODO: buka riwayat status LED.
        },
      ),
      _DeviceTile(
        icon: Icons.volume_up_rounded,
        color: AppColors.danger,
        title: 'Buzzer',
        value: buzzerEnabled ? 'ON' : 'OFF',
        valueColor: buzzerEnabled ? AppColors.danger : AppColors.offline,
        trailing: _buzzerBusy
            ? const Padding(
                padding: EdgeInsets.only(right: 8, top: 4),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
              )
            : GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Saat disabled, ketukan menampilkan alasannya.
                onTap: canToggle
                    ? null
                    : () => _showToast(disabledMsg ?? '', error: true),
                child: Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: buzzerEnabled,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    // Toggle hanya untuk MEMATIKAN buzzer.
                    onChanged: canToggle ? (_) => _onBuzzerToggle() : null,
                  ),
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

  // ───────────────────────── Simulator (untuk screenshot/demo) ─────────────────────────

  Widget _buildSimulator() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simulasi (hapus saat produksi)',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text('Kadar CO: ${coLevel.round()} ppm',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          Slider(
            value: coLevel,
            min: 0,
            max: _maxPpm,
            divisions: 200,
            onChanged: (v) => setState(() {
              coLevel = v;
              _evaluate();
            }),
          ),
          Text('Baterai: ${batteryVolt.toStringAsFixed(1)} V',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          Slider(
            value: batteryVolt,
            min: 10,
            max: 13,
            divisions: 30,
            onChanged: (v) => setState(() => batteryVolt = v),
          ),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text('ESP32 online', style: TextStyle(fontSize: 13)),
            value: espConnected,
            onChanged: (v) => setState(() {
              espConnected = v;
              _evaluate();
            }),
          ),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text('Sensor error', style: TextStyle(fontSize: 13)),
            value: sensorError,
            onChanged: (v) => setState(() {
              sensorError = v;
              _evaluate();
            }),
          ),
        ],
      ),
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
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final Color? valueColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
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
                if (trailing != null)
                  trailing!
                else if (onTap != null)
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary, size: 20),
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
      ),
    );
  }
}

// ───────────────────────── Toast & skeleton ─────────────────────────

class _Toast extends StatelessWidget {
  const _Toast({required this.message, this.error = false});

  final String message;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: error ? AppColors.danger : AppColors.darkMid,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              error ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({this.height, this.radius = 16});

  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE6EDE9),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child});

  final Widget child;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = _c.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            colors: const [
              Color(0xFFE6EDE9),
              Color(0xFFF6F9F7),
              Color(0xFFE6EDE9),
            ],
            stops: [
              (t - 0.3).clamp(0.0, 1.0).toDouble(),
              t,
              (t + 0.3).clamp(0.0, 1.0).toDouble(),
            ],
          ).createShader(rect),
          child: child,
        );
      },
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