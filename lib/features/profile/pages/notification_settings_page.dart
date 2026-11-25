import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

const Color _track = Color(0xFFE6F0EA);
const Color _switchOff = Color(0xFFCBD6DB);

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // TODO: simpan dan baca nilai ini dari shared_preferences.
  bool _enabled = true;
  bool _coAlert = true;
  bool _deviceStatus = true;
  bool _sound = true;
  bool _vibration = true;
  double _volume = 0.8;
  String _tone = 'Sirene';

  static const _tones = ['Sirene', 'Beep', 'Lonceng', 'Klakson'];

  // Peringatan CO menyangkut keselamatan, jadi minta konfirmasi saat dimatikan.
  Future<bool> _confirmOff(String title) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: const Text(
          'Anda tidak akan diberi tahu saat kadar CO berbahaya.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Matikan'),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _setEnabled(bool v) async {
    if (!v && !await _confirmOff('Matikan semua notifikasi?')) return;
    if (!mounted) return;
    setState(() => _enabled = v);
  }

  Future<void> _setCoAlert(bool v) async {
    if (!v && !await _confirmOff('Matikan peringatan CO?')) return;
    if (!mounted) return;
    setState(() => _coAlert = v);
  }

  Future<void> _pickTone() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih nada peringatan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              for (final t in _tones)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  minVerticalPadding: 14,
                  title: Text(
                    t,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: t == _tone ? FontWeight.w800 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: t == _tone
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary)
                      : null,
                  onTap: () => Navigator.pop(context, t),
                ),
            ],
          ),
        ),
      ),
    );
    if (result != null) setState(() => _tone = result);
  }

  void _sendTest() {
    // TODO: kirim notifikasi uji coba sungguhan.
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Notifikasi uji dikirim',
                style: TextStyle(
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
              'Notifikasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Atur pesan dan suara peringatan',
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
            _Group(
              children: [
                _SwitchRow(
                  icon: Icons.notifications_active_outlined,
                  title: 'Notifikasi',
                  subtitle: 'Terima pesan saat ada bahaya atau masalah',
                  value: _enabled,
                  onChanged: _setEnabled,
                ),
              ],
            ),
            if (!_enabled) ...[
              const SizedBox(height: 12),
              const _WarningNote(
                'Notifikasi sedang mati. Anda tidak akan diberi tahu saat '
                'kadar CO berbahaya.',
              ),
            ],
            const SizedBox(height: 22),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _enabled ? 1 : 0.45,
              child: IgnorePointer(
                ignoring: !_enabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Pesan yang diterima'),
                    const SizedBox(height: 10),
                    _Group(
                      children: [
                        _SwitchRow(
                          icon: Icons.warning_amber_rounded,
                          title: 'Peringatan CO',
                          subtitle: 'Saat kadar CO melewati batas. '
                              'Sebaiknya tetap aktif.',
                          value: _coAlert,
                          color: AppColors.danger,
                          onChanged: _setCoAlert,
                        ),
                        _SwitchRow(
                          icon: Icons.developer_board_rounded,
                          title: 'Status perangkat',
                          subtitle: 'Saat ESP32 terputus atau bermasalah',
                          value: _deviceStatus,
                          onChanged: (v) => setState(() => _deviceStatus = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const _SectionTitle('Suara dan getaran'),
                    const SizedBox(height: 10),
                    _Group(
                      children: [
                        _SwitchRow(
                          icon: Icons.volume_up_outlined,
                          title: 'Suara',
                          subtitle: 'Bunyi saat pesan masuk',
                          value: _sound,
                          onChanged: (v) => setState(() => _sound = v),
                        ),
                        _SwitchRow(
                          icon: Icons.vibration_rounded,
                          title: 'Getaran',
                          subtitle: 'Getar saat pesan masuk',
                          value: _vibration,
                          onChanged: (v) => setState(() => _vibration = v),
                        ),
                        if (_sound) ...[
                          _NavRow(
                            icon: Icons.music_note_rounded,
                            title: 'Nada peringatan',
                            value: _tone,
                            onTap: _pickTone,
                          ),
                          _VolumeRow(
                            value: _volume,
                            onChanged: (v) => setState(() => _volume = v),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _sendTest,
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text(
                          'Coba kirim notifikasi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(
                            color: AppColors.primary.withValues(alpha: 0.4),
                          ),
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(4, 8, 4, 0),
                      child: Text(
                        'Gunakan untuk memastikan notifikasi berfungsi di '
                        'ponsel ini.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
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

class _WarningNote extends StatelessWidget {
  const _WarningNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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

class _IconCircle extends StatelessWidget {
  const _IconCircle(this.icon, {this.color = AppColors.primary});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 22, color: color),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 68),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              children: [
                _IconCircle(icon, color: color),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  thumbColor: const WidgetStatePropertyAll(Colors.white),
                  trackColor: WidgetStateProperty.resolveWith(
                    (s) => s.contains(WidgetState.selected)
                        ? AppColors.primary
                        : _switchOff,
                  ),
                  trackOutlineColor:
                      const WidgetStatePropertyAll(Colors.transparent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, thickness: 1, indent: 70, color: _track),
        InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  _IconCircle(icon),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VolumeRow extends StatelessWidget {
  const _VolumeRow({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1, thickness: 1, indent: 70, color: _track),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(
            children: [
              const _IconCircle(Icons.volume_down_rounded),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Volume',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 5,
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: _track,
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withValues(alpha: 0.14),
                      ),
                      child: Slider(
                        value: value,
                        label: '${(value * 100).round()}%',
                        onChanged: onChanged,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '${(value * 100).round()}%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}