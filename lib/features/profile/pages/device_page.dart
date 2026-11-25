import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';

const Color _track = Color(0xFFE6F0EA);

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  // TODO: ganti dengan status asli dari ESP32 / Firebase.
  bool _connected = true;
  final bool _lowBattery = false;
  final bool _sensorError = false;

  bool _connecting = false;
  bool _saving = false;

  final _nameCtrl = TextEditingController(text: 'ESP32 Mobil');
  final _intervalCtrl = TextEditingController(text: '5');
  bool _nameTouched = false;
  bool _intervalTouched = false;

  // Pilihan cepat interval (detik, label)
  static const List<(int, String)> _intervalOptions = [
    (5, '5 detik'),
    (10, '10 detik'),
    (30, '30 detik'),
    (60, '1 menit'),
    (300, '5 menit'),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _intervalCtrl.dispose();
    super.dispose();
  }

  // ───────────── Validasi ─────────────

  String? get _nameError {
    final v = _nameCtrl.text.trim();
    if (v.isEmpty) return 'Isi nama perangkat';
    if (v.length < 3) return 'Minimal 3 karakter';
    if (!RegExp(r'^[A-Za-z0-9 ]+$').hasMatch(v)) {
      return 'Hanya boleh huruf, angka, dan spasi';
    }
    return null;
  }

  String? get _intervalError {
    final n = int.tryParse(_intervalCtrl.text.trim());
    if (n == null || n < 5 || n > 3600) {
      return 'Isi angka antara 5 dan 3600 detik';
    }
    return null;
  }

  bool get _valid => _nameError == null && _intervalError == null;

  // ───────────── Aksi ─────────────

  Future<void> _connect() async {
    setState(() => _connecting = true);
    try {
      // TODO: sambungkan ke ESP32 sungguhan.
      await Future<void>.delayed(const Duration(seconds: 2))
          .timeout(const Duration(seconds: 5));
      if (!mounted) return;
      setState(() {
        _connected = true;
        _connecting = false;
      });
      _showMessage('Perangkat berhasil terhubung');
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _connecting = false);
      _showMessage('Perangkat tidak merespons. Coba lagi.', error: true);
    }
  }

  Future<void> _disconnect() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Putuskan perangkat?'),
        content: const Text(
          'Data kadar CO tidak akan diterima sampai perangkat '
          'dihubungkan lagi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Putuskan'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _connected = false);
    _showMessage('Perangkat diputus');
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      // TODO: kirim nama perangkat dan interval ke ESP32 / Firebase.
      await Future<void>.delayed(const Duration(seconds: 1))
          .timeout(const Duration(seconds: 5));
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('Pengaturan disimpan');
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

  // ───────────── Tampilan ─────────────

  @override
  Widget build(BuildContext context) {
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
              'Perangkat ESP32',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Lihat status dan atur alat pendeteksi',
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
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          children: [
            _StatusCard(
              connected: _connected,
              lowBattery: _lowBattery,
              sensorError: _sensorError,
            ),

            // Saat offline, tombol hubungkan jadi aksi utama di bagian atas.
            if (!_connected) ...[
              const SizedBox(height: 14),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: _connecting ? null : _connect,
                  icon: _connecting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.link_rounded),
                  label: Text(
                    _connecting ? 'Menghubungkan...' : 'Hubungkan perangkat',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 22),
            const _SectionTitle('Informasi perangkat'),
            const SizedBox(height: 10),
            _InfoGroup(
              rows: [
                const _InfoRow('ID perangkat', 'ESP32-CO-01'),
                const _InfoRow('Firmware', 'v1.0.2'),
                _InfoRow('Kekuatan sinyal', _connected ? 'Kuat' : '-'),
                _InfoRow(
                  'Terakhir kirim data',
                  _connected ? 'Baru saja' : '-',
                ),
              ],
            ),

            const SizedBox(height: 22),
            const _SectionTitle('Pengaturan perangkat'),
            const SizedBox(height: 10),
            _FormField(
              controller: _nameCtrl,
              label: 'Nama perangkat',
              hint: 'Contoh: ESP32 Mobil',
              maxLength: 20,
              error: _nameTouched ? _nameError : null,
              onChanged: (_) => setState(() => _nameTouched = true),
            ),
            const SizedBox(height: 14),
            _FormField(
              controller: _intervalCtrl,
              label: 'Kirim data setiap',
              hint: '5 - 3600',
              suffix: 'detik',
              helper: 'Makin kecil angkanya, makin sering data dikirim.',
              number: true,
              error: _intervalTouched ? _intervalError : null,
              onChanged: (_) => setState(() => _intervalTouched = true),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in _intervalOptions) _intervalChip(o.$1, o.$2),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: (_valid && _connected && !_saving) ? _save : null,
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
                        'Simpan pengaturan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            if (!_connected)
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
                child: Text(
                  'Hubungkan perangkat dulu untuk menyimpan pengaturan.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

            if (_connected) ...[
              const SizedBox(height: 28),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _disconnect,
                  icon: const Icon(Icons.link_off_rounded, size: 20),
                  label: const Text(
                    'Putuskan perangkat',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: BorderSide(
                      color: AppColors.danger.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _intervalChip(int seconds, String label) {
    final selected = int.tryParse(_intervalCtrl.text.trim()) == seconds;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: AppColors.primary.withValues(alpha: 0.16),
      backgroundColor: AppColors.surface,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        color: selected ? AppColors.primary : AppColors.textSecondary,
      ),
      onSelected: (_) => setState(() {
        _intervalCtrl.text = '$seconds';
        _intervalTouched = true;
      }),
    );
  }
}

// ───────────────────────── Kartu status ─────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.connected,
    required this.lowBattery,
    required this.sensorError,
  });

  final bool connected;
  final bool lowBattery;
  final bool sensorError;

  @override
  Widget build(BuildContext context) {
    // Prioritas: tidak terhubung > sensor error > baterai rendah > normal.
    final Color color;
    final IconData icon;
    final String label;
    final String message;

    if (!connected) {
      color = AppColors.offline;
      icon = Icons.wifi_off_rounded;
      label = 'Tidak terhubung';
      message = 'Aplikasi tidak menerima data CO. Pastikan ESP32 menyala '
          'dan berada dalam jangkauan Wi-Fi.';
    } else if (sensorError) {
      color = AppColors.danger;
      icon = Icons.sensors_off_rounded;
      label = 'Sensor bermasalah';
      message = 'Sensor CO tidak terbaca. Periksa kabel sensor atau '
          'ganti sensor.';
    } else if (lowBattery) {
      color = AppColors.warning;
      icon = Icons.battery_alert_rounded;
      label = 'Baterai rendah';
      message = 'Daya perangkat hampir habis. Segera isi daya.';
    } else {
      color = AppColors.online;
      icon = Icons.check_circle_rounded;
      label = 'Terhubung';
      message = 'Perangkat aktif dan mengirim data kadar CO.';
    }

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: 'Perangkat ESP32, $label. $message',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.3)),
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
                    color: color.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.memory_rounded, color: color, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'ESP32',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: color.withValues(alpha: 0.28)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 15, color: color),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Informasi ─────────────────────────

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

class _InfoRow {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;
}

class _InfoGroup extends StatelessWidget {
  const _InfoGroup({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: _track),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
              child: Row(
                children: [
                  Text(
                    rows[i].label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    rows[i].value,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
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

// ───────────────────────── Form ─────────────────────────

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.suffix,
    this.helper,
    this.maxLength,
    this.number = false,
    this.error,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? suffix;
  final String? helper;
  final int? maxLength;
  final bool number;
  final String? error;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: w),
        );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLength: maxLength,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      inputFormatters:
          number ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: const TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        helperText: helper,
        helperMaxLines: 2,
        filled: true,
        fillColor: AppColors.surface,
        errorText: error,
        errorMaxLines: 2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: border(AppColors.border),
        focusedBorder: border(AppColors.primary, 1.5),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger, 1.5),
      ),
    );
  }
}