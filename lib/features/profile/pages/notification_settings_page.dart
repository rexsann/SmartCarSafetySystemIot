import 'package:flutter/material.dart';

/// Warna lokal, sama dengan halaman lain. Kalau mau, pindahkan ke AppColors.
class _C {
  static const header = Color(0xFF0B3A3C);
  static const background = Color(0xFFF2F7F9);
  static const border = Color(0xFFE3EBEF);
  static const divider = Color(0xFFE9EFF2);
  static const iconBg = Color(0xFFE6F1F5);
  static const iconColor = Color(0xFF123B3F);
  static const title = Color(0xFF12292E);
  static const subtitle = Color(0xFF8A9AA1);
  static const green = Color(0xFF0F9D77);
  static const accent = Color(0xFF2DBE75);
  static const danger = Color(0xFFFF2D4B);
}

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // TODO: simpan & baca nilai ini dari shared_preferences / backend.
  bool _enabled = true;
  bool _coAlert = true;
  bool _systemStatus = true;
  bool _location = false;
  bool _sound = true;
  bool _vibration = true;
  double _volume = 0.8;
  String _tone = 'Sirene';

  static const _tones = ['Sirene', 'Beep', 'Lonceng', 'Klakson'];

  Future<void> _pickTone() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
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
                    color: _C.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nada peringatan',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _C.title,
                ),
              ),
              const SizedBox(height: 8),
              for (final t in _tones)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    t,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          t == _tone ? FontWeight.w700 : FontWeight.w500,
                      color: _C.title,
                    ),
                  ),
                  trailing: t == _tone
                      ? const Icon(Icons.check_rounded, color: _C.green)
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
              'Notifikasi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Atur notifikasi & suara',
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
            _Group(
              children: [
                _SwitchRow(
                  icon: Icons.notifications_active_outlined,
                  title: 'Aktifkan notifikasi',
                  subtitle: 'Terima peringatan dari perangkat',
                  value: _enabled,
                  onChanged: (v) => setState(() => _enabled = v),
                ),
              ],
            ),
            const SizedBox(height: 22),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _enabled ? 1 : 0.45,
              child: IgnorePointer(
                ignoring: !_enabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('Jenis notifikasi'),
                    _Group(
                      children: [
                        _SwitchRow(
                          icon: Icons.warning_amber_rounded,
                          title: 'Peringatan CO',
                          subtitle: 'Saat kadar gas melewati batas',
                          value: _coAlert,
                          iconColor: _C.danger,
                          onChanged: (v) => setState(() => _coAlert = v),
                        ),
                        _SwitchRow(
                          icon: Icons.wifi_rounded,
                          title: 'Status sistem',
                          subtitle: 'Koneksi & kondisi perangkat',
                          value: _systemStatus,
                          onChanged: (v) => setState(() => _systemStatus = v),
                        ),
                        _SwitchRow(
                          icon: Icons.location_on_outlined,
                          title: 'Lokasi kendaraan',
                          subtitle: 'Pembaruan lokasi GPS',
                          value: _location,
                          onChanged: (v) => setState(() => _location = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const _SectionLabel('Suara & getaran'),
                    _Group(
                      children: [
                        _SwitchRow(
                          icon: Icons.volume_up_outlined,
                          title: 'Suara',
                          subtitle: 'Bunyi saat notifikasi masuk',
                          value: _sound,
                          onChanged: (v) => setState(() => _sound = v),
                        ),
                        _SwitchRow(
                          icon: Icons.vibration_rounded,
                          title: 'Getaran',
                          subtitle: 'Getar saat notifikasi masuk',
                          value: _vibration,
                          onChanged: (v) => setState(() => _vibration = v),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                          child: _sound
                              ? Column(
                                  children: [
                                    _NavRow(
                                      icon: Icons.music_note_rounded,
                                      title: 'Nada peringatan',
                                      value: _tone,
                                      onTap: _pickTone,
                                    ),
                                    _VolumeRow(
                                      value: _volume,
                                      onChanged: (v) =>
                                          setState(() => _volume = v),
                                    ),
                                  ],
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: kirim notifikasi uji coba.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notifikasi uji dikirim'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text(
                          'Kirim notifikasi uji',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _C.header,
                          side: const BorderSide(color: _C.border),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _C.subtitle,
        ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
        boxShadow: [
          BoxShadow(
            color: _C.header.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 68,
                color: _C.divider,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox(this.icon, {this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? _C.iconColor;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color == null ? _C.iconBg : c.withAlpha(30),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, size: 20, color: c),
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
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Row(
          children: [
            _IconBox(icon, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _C.title,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _C.subtitle),
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
                    ? _C.accent
                    : const Color(0xFFCBD6DB),
              ),
              trackOutlineColor:
                  const WidgetStatePropertyAll(Colors.transparent),
            ),
          ],
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
        const Divider(height: 1, thickness: 1, indent: 68, color: _C.divider),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                _IconBox(icon),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _C.title,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _C.green,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: _C.subtitle),
              ],
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
        const Divider(height: 1, thickness: 1, indent: 68, color: _C.divider),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(
            children: [
              const _IconBox(Icons.volume_down_rounded),
              const SizedBox(width: 6),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    activeTrackColor: _C.accent,
                    inactiveTrackColor: _C.divider,
                    thumbColor: _C.accent,
                    overlayColor: _C.accent.withAlpha(30),
                  ),
                  child: Slider(value: value, onChanged: onChanged),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '${(value * 100).round()}%',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _C.subtitle,
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