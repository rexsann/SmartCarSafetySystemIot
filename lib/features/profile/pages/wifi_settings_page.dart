import 'package:flutter/material.dart';

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
}

class _Network {
  const _Network(this.name, this.signal, this.secured);
  final String name;
  final int signal; // 1..3
  final bool secured;
}

class WifiSettingsPage extends StatefulWidget {
  const WifiSettingsPage({super.key});

  @override
  State<WifiSettingsPage> createState() => _WifiSettingsPageState();
}

class _WifiSettingsPageState extends State<WifiSettingsPage> {
  // TODO: ganti dengan hasil pindai Wi-Fi asli dari ESP32.
  static const _networks = <_Network>[
    _Network('Rumah_Wifi', 3, true),
    _Network('Kantor_Guest', 2, true),
    _Network('Hotspot_HP', 2, true),
    _Network('Warkop_Free', 1, false),
  ];

  String _connected = 'Rumah_Wifi';

  Future<void> _connect(_Network n) async {
    if (n.name == _connected) return;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PasswordSheet(network: n),
    );
    if (ok == true) setState(() => _connected = n.name);
  }

  @override
  Widget build(BuildContext context) {
    final others = _networks.where((n) => n.name != _connected).toList();
    final current = _networks.firstWhere((n) => n.name == _connected);

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
              'Koneksi Wi-Fi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Konfigurasi jaringan',
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withAlpha(165),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Pindai ulang',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
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
            const _Label('Terhubung'),
            _Card(
              children: [_NetworkRow(network: current, connected: true)],
            ),
            const SizedBox(height: 22),
            const _Label('Jaringan tersedia'),
            _Card(
              children: [
                for (final n in others)
                  _NetworkRow(network: n, onTap: () => _connect(n)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

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

class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
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

class _NetworkRow extends StatelessWidget {
  const _NetworkRow({
    required this.network,
    this.connected = false,
    this.onTap,
  });

  final _Network network;
  final bool connected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (network.signal) {
      3 => Icons.wifi_rounded,
      2 => Icons.wifi_2_bar_rounded,
      _ => Icons.wifi_1_bar_rounded,
    };

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: connected ? _C.green.withAlpha(30) : _C.iconBg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                size: 20,
                color: connected ? _C.green : _C.iconColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                network.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _C.title,
                ),
              ),
            ),
            if (connected)
              const Icon(Icons.check_circle_rounded, color: _C.green, size: 22)
            else if (network.secured)
              const Icon(Icons.lock_outline_rounded,
                  color: _C.subtitle, size: 18),
          ],
        ),
      ),
    );
  }
}

class _PasswordSheet extends StatefulWidget {
  const _PasswordSheet({required this.network});

  final _Network network;

  @override
  State<_PasswordSheet> createState() => _PasswordSheetState();
}

class _PasswordSheetState extends State<_PasswordSheet> {
  final _controller = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secured = widget.network.secured;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.network.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _C.title,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            secured ? 'Masukkan kata sandi jaringan' : 'Jaringan terbuka',
            style: const TextStyle(fontSize: 13, color: _C.subtitle),
          ),
          if (secured) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: 'Kata sandi',
                filled: true,
                fillColor: _C.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
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
            height: 50,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: _C.header,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Hubungkan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}