import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

const Color _track = Color(0xFFE6F0EA);

// TODO: sesuaikan dengan data proyek Anda.
const String _appName = 'GasGuard';
const String _version = '1.0.0';
const String _developer = 'Muhammad Ihsan & Nicolas Situmorang'; // tambahkan nama anggota lain

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
        title: const Text(
          'Tentang aplikasi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
          children: [
            // ───────── Identitas aplikasi ─────────
            const Center(child: _AppLogo(size: 128)),
            const SizedBox(height: 16),
            const Text(
              _appName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Versi $_version',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Memantau kadar gas karbon monoksida (CO) di kabin kendaraan '
                'secara langsung dan memberi peringatan dini demi '
                'keselamatan berkendara.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            // ───────── Cara kerja ─────────
            const SizedBox(height: 26),
            const _SectionTitle('Cara kerja'),
            const SizedBox(height: 10),
            const _Card(
              children: [
                _StepRow(
                  number: 1,
                  title: 'Sensor membaca udara',
                  text: 'Sensor CO di kabin mengukur kadar gas.',
                ),
                _StepRow(
                  number: 2,
                  title: 'ESP32 mengirim data',
                  text: 'ESP32 meneruskan hasilnya lewat Wi-Fi ke Firebase.',
                ),
                _StepRow(
                  number: 3,
                  title: 'Aplikasi memberi tahu',
                  text: 'Anda melihat kadar CO dan menerima peringatan '
                      'saat kadarnya berbahaya.',
                ),
              ],
            ),

            // ───────── Informasi ─────────
            const SizedBox(height: 22),
            const _SectionTitle('Informasi'),
            const SizedBox(height: 10),
            const _Card(
              children: [
                _InfoRow('Versi', _version),
                _InfoRow('Perangkat', 'ESP32 dan sensor CO'),
                _InfoRow('Penyimpanan data', 'Firebase'),
                _InfoRow('Pengembang', _developer),
              ],
            ),

            // ───────── Catatan keselamatan ─────────
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Aplikasi ini alat bantu, bukan pengganti kewaspadaan. '
                      'Jika Anda merasa pusing, mual, atau mengantuk saat '
                      'berkendara, hentikan kendaraan di tempat aman dan '
                      'buka jendela.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13.5,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),
            const Text(
              '© 2026 $_appName',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Komponen ─────────────────────────

/// Logo aplikasi berbentuk lingkaran. Berkas: assets/images/logo.jpg
class _AppLogo extends StatelessWidget {
  const _AppLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Logo $_appName',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.28),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        // Dipotong bulat dan sedikit diperbesar agar tepi hitam gambar
        // tidak terlihat di latar terang.
        child: ClipOval(
          child: Transform.scale(
            scale: 1.1,
            child: Image.asset(
              'assets/images/logo.jpg',
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.primaryDark,
                child: const Icon(
                  Icons.shield_rounded,
                  color: AppColors.primaryLight,
                  size: 48,
                ),
              ),
            ),
          ),
        ),
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
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, thickness: 1, color: _track),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.title,
    required this.text,
  });

  final int number;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.5,
                    height: 1.4,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}