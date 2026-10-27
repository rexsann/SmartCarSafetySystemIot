import 'package:flutter/material.dart';

class _C {
  static const header = Color(0xFF0B3A3C);
  static const headerSoft = Color(0xFF136B66);
  static const background = Color(0xFFF2F7F9);
  static const border = Color(0xFFE3EBEF);
  static const divider = Color(0xFFE9EFF2);
  static const title = Color(0xFF12292E);
  static const subtitle = Color(0xFF8A9AA1);
  static const greenLight = Color(0xFF5BE0B0);
  static const accent = Color(0xFF2DBE75);
  static const danger = Color(0xFFFF2D4B);
}

class DevicePage extends StatefulWidget {
  const DevicePage({super.key});

  @override
  State<DevicePage> createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  // TODO: ganti dengan status koneksi asli dari ESP32 / Blynk.
  bool _connected = true;

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
              'Perangkat',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Hubungkan ESP32',
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
            _StatusCard(connected: _connected),
            const SizedBox(height: 20),
            _InfoGroup(
              rows: [
                const _InfoRow('ID perangkat', 'ESP32-CO-01'),
                const _InfoRow('Firmware', 'v1.0.2'),
                _InfoRow('Kekuatan sinyal', _connected ? 'Kuat' : '-'),
                _InfoRow('Sinkron terakhir', _connected ? 'Baru saja' : '-'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: _connected
                  ? OutlinedButton(
                      onPressed: () => setState(() => _connected = false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _C.danger,
                        side: BorderSide(color: _C.danger.withAlpha(90)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Putuskan perangkat',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : FilledButton(
                      onPressed: () => setState(() => _connected = true),
                      style: FilledButton.styleFrom(
                        backgroundColor: _C.header,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Hubungkan perangkat',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
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

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_C.header, _C.headerSoft],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.memory_rounded,
                color: Colors.white, size: 32),
          ),
          const SizedBox(height: 14),
          const Text(
            'ESP32',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: connected ? _C.greenLight : _C.subtitle,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  connected ? 'Terhubung' : 'Tidak terhubung',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: _C.divider),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Text(
                    rows[i].label,
                    style: const TextStyle(fontSize: 14, color: _C.subtitle),
                  ),
                  const Spacer(),
                  Text(
                    rows[i].value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.title,
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