import 'package:flutter/material.dart';

class _C {
  static const header = Color(0xFF0B3A3C);
  static const headerSoft = Color(0xFF136B66);
  static const background = Color(0xFFF2F7F9);
  static const border = Color(0xFFE3EBEF);
  static const divider = Color(0xFFE9EFF2);
  static const title = Color(0xFF12292E);
  static const subtitle = Color(0xFF8A9AA1);
  static const body = Color(0xFF5B6B72);
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: _C.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
          children: [
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_C.header, _C.headerSoft],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: _C.header.withAlpha(60),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sensors_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 18),
            // TODO: ganti dengan nama aplikasi kamu.
            const Text(
              'CO Monitor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: _C.title,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Versi 1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _C.subtitle),
            ),
            const SizedBox(height: 18),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Pantau kadar gas karbon monoksida di kabin kendaraan secara '
                'real-time dan terima peringatan dini demi keselamatan '
                'berkendara.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.55, color: _C.body),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _C.border),
              ),
              child: const Column(
                children: [
                  _Row('Versi', '1.0.0'),
                  Divider(height: 1, color: _C.divider),
                  _Row('Perangkat', 'ESP32'),
                  Divider(height: 1, color: _C.divider),
                  _Row('Platform', 'Flutter'),
                  Divider(height: 1, color: _C.divider),
                  // TODO: ganti dengan nama kamu / tim.
                  _Row('Pengembang', 'Nama Kamu'),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              '© 2026 CO Monitor',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: _C.subtitle),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: _C.subtitle),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _C.title,
            ),
          ),
        ],
      ),
    );
  }
}