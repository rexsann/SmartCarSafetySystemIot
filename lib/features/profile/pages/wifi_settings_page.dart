import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

const Color _track = Color(0xFFE6F0EA);

class _Network {
  const _Network(this.name, this.signal, this.secured);
  final String name;
  final int signal; // 1 = lemah, 2 = sedang, 3 = kuat
  final bool secured;

  String get signalLabel => switch (signal) {
        3 => 'Sinyal kuat',
        2 => 'Sinyal sedang',
        _ => 'Sinyal lemah',
      };
}

class WifiSettingsPage extends StatefulWidget {
  const WifiSettingsPage({super.key});

  @override
  State<WifiSettingsPage> createState() => _WifiSettingsPageState();
}

class _WifiSettingsPageState extends State<WifiSettingsPage> {
  // TODO: ganti dengan hasil pindai Wi-Fi asli dari ESP32.
  final List<_Network> _networks = <_Network>[
    const _Network('Rumah_Wifi', 3, true),
    const _Network('Kantor_Guest', 2, true),
    const _Network('Hotspot_HP', 2, true),
    const _Network('Warkop_Free', 1, false),
  ];

  String _connected = 'Rumah_Wifi';
  bool _scanning = false;
  String? _connecting; // nama jaringan yang sedang dihubungkan

  @override
  void initState() {
    super.initState();
    _scan();
  }

  Future<void> _scan() async {
    setState(() => _scanning = true);
    // TODO: panggil pindai Wi-Fi asli dari ESP32.
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _scanning = false);
  }

  Future<void> _sendToDevice(String ssid, String password) async {
    // TODO: ganti dengan perintah koneksi asli ke ESP32.
    await Future<void>.delayed(const Duration(seconds: 2));
  }

  Future<void> _connectTo(
    String ssid,
    String password, {
    int signal = 2,
    bool secured = true,
  }) async {
    setState(() => _connecting = ssid);
    try {
      await _sendToDevice(ssid, password).timeout(const Duration(seconds: 5));
      if (!mounted) return;
      setState(() {
        if (!_networks.any((n) => n.name == ssid)) {
          _networks.add(_Network(ssid, signal, secured));
        }
        _connected = ssid;
        _connecting = null;
      });
      _showMessage('Berhasil terhubung ke $ssid');
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _connecting = null);
      _showMessage('Perangkat tidak merespons. Coba lagi.', error: true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _connecting = null);
      _showMessage('Gagal terhubung ke $ssid', error: true);
    }
  }

  Future<void> _onTapNetwork(_Network n) async {
    if (n.name == _connected || _connecting != null) return;
    final result = await _openSheet(network: n);
    if (result == null) return;
    await _connectTo(
      result.$1,
      result.$2,
      signal: n.signal,
      secured: n.secured,
    );
  }

  Future<void> _addManual() async {
    if (_connecting != null) return;
    final result = await _openSheet();
    if (result == null) return;
    await _connectTo(result.$1, result.$2);
  }

  Future<(String, String)?> _openSheet({_Network? network}) {
    return showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _WifiSheet(network: network),
    );
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
    final others = _networks.where((n) => n.name != _connected).toList();
    final current = _networks.firstWhere((n) => n.name == _connected);

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
              'Wi-Fi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Jaringan yang dipakai perangkat ESP32',
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
            const _InfoBanner(
              'ESP32 memakai Wi-Fi ini untuk mengirim data kadar CO ke '
              'aplikasi. Pilih jaringan yang punya internet.',
            ),
            const SizedBox(height: 20),
            const _SectionTitle('Sedang dipakai'),
            const SizedBox(height: 10),
            _Card(
              children: [_NetworkRow(network: current, connected: true)],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(child: _SectionTitle('Jaringan tersedia')),
                TextButton.icon(
                  onPressed: (_scanning || _connecting != null) ? null : _scan,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Pindai ulang'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (_scanning)
              const _Card(children: [_MessageRow(loading: true, text: 'Mencari jaringan...')])
            else if (others.isEmpty)
              const _Card(
                children: [
                  _MessageRow(
                    text: 'Tidak ada jaringan lain. Tekan "Pindai ulang" '
                        'untuk mencari lagi.',
                  ),
                ],
              )
            else
              _Card(
                children: [
                  for (final n in others)
                    _NetworkRow(
                      network: n,
                      loading: _connecting == n.name,
                      onTap: _connecting == null ? () => _onTapNetwork(n) : null,
                    ),
                ],
              ),
            const SizedBox(height: 22),
            const _SectionTitle('Jaringan tidak terlihat?'),
            const SizedBox(height: 10),
            _Card(
              children: [
                InkWell(
                  onTap: _connecting == null ? _addManual : null,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 64),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              size: 22,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Tambah jaringan manual',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
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
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Komponen ─────────────────────────

class _InfoBanner extends StatelessWidget {
  const _InfoBanner(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.info, size: 20),
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
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
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

class _MessageRow extends StatelessWidget {
  const _MessageRow({required this.text, this.loading = false});

  final String text;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          if (loading) ...[
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkRow extends StatelessWidget {
  const _NetworkRow({
    required this.network,
    this.connected = false,
    this.loading = false,
    this.onTap,
  });

  final _Network network;
  final bool connected;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (network.signal) {
      3 => Icons.wifi_rounded,
      2 => Icons.wifi_2_bar_rounded,
      _ => Icons.wifi_1_bar_rounded,
    };
    final color = connected ? AppColors.online : AppColors.primary;
    final detail = connected
        ? 'Terhubung • ${network.signalLabel}'
        : '${network.signalLabel} • ${network.secured ? 'Berkata sandi' : 'Terbuka'}';

    return Semantics(
      button: onTap != null,
      excludeSemantics: true,
      label: '${network.name}. $detail',
      child: InkWell(
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
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 22, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        network.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        style: TextStyle(
                          fontSize: 13,
                          color: connected
                              ? AppColors.online
                              : AppColors.textSecondary,
                          fontWeight:
                              connected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (loading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.primary,
                    ),
                  )
                else if (connected)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.online, size: 24)
                else if (network.secured)
                  const Icon(Icons.lock_outline_rounded,
                      color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Lembar sandi / jaringan manual ─────────────────────────

/// Jika [network] null, lembar ini dipakai untuk menambah jaringan manual
/// (SSID + kata sandi). Hasil: (ssid, kata sandi).
class _WifiSheet extends StatefulWidget {
  const _WifiSheet({this.network});

  final _Network? network;

  @override
  State<_WifiSheet> createState() => _WifiSheetState();
}

class _WifiSheetState extends State<_WifiSheet> {
  final _ssid = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _ssidTouched = false;
  bool _passTouched = false;

  bool get _manual => widget.network == null;
  bool get _needPassword => _manual || widget.network!.secured;

  @override
  void dispose() {
    _ssid.dispose();
    _password.dispose();
    super.dispose();
  }

  String? get _ssidError => (_manual && _ssid.text.trim().isEmpty)
      ? 'Isi nama Wi-Fi (SSID)'
      : null;

  String? get _passError {
    if (!_needPassword) return null;
    final v = _password.text;
    if (v.isEmpty) return 'Isi kata sandi Wi-Fi';
    if (v.length < 8) return 'Kata sandi minimal 8 karakter';
    return null;
  }

  bool get _valid => _ssidError == null && _passError == null;

  void _submit() {
    if (!_valid) return;
    final ssid = _manual ? _ssid.text.trim() : widget.network!.name;
    Navigator.pop(context, (ssid, _needPassword ? _password.text : ''));
  }

  InputDecoration _decoration(String label, String? error, {Widget? suffix}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.background,
      errorText: error,
      suffixIcon: suffix,
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.primary, 1.5),
      errorBorder: border(AppColors.danger),
      focusedErrorBorder: border(AppColors.danger, 1.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _manual
        ? 'Masukkan nama dan kata sandi Wi-Fi'
        : _needPassword
            ? 'Masukkan kata sandi Wi-Fi ini'
            : 'Jaringan terbuka, tidak perlu kata sandi';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        22,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _manual ? 'Tambah jaringan manual' : widget.network!.name,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
            ),
          ),
          if (_manual) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _ssid,
              autofocus: true,
              textInputAction: TextInputAction.next,
              onChanged: (_) => setState(() => _ssidTouched = true),
              decoration: _decoration(
                'Nama Wi-Fi (SSID)',
                _ssidTouched ? _ssidError : null,
              ),
            ),
          ],
          if (_needPassword) ...[
            const SizedBox(height: 14),
            TextField(
              controller: _password,
              obscureText: _obscure,
              autofocus: !_manual,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() => _passTouched = true),
              onSubmitted: (_) => _submit(),
              decoration: _decoration(
                'Kata sandi',
                _passTouched ? _passError : null,
                suffix: IconButton(
                  tooltip: _obscure ? 'Tampilkan sandi' : 'Sembunyikan sandi',
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _valid ? _submit : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Hubungkan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}