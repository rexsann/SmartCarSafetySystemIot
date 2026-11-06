import 'package:flutter/material.dart';

/// Palet utama aplikasi: hijau hutan (forest) + emerald + emas champagne.
/// Semua halaman sebaiknya memakai warna dari sini, bukan Color(0x...) langsung.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------
  // Warna utama
  // ---------------------------------------------------------------------
  static const Color primary = Color(0xFF10B981); // emerald
  static const Color primaryLight = Color(0xFF6EE7B7); // mint
  static const Color primaryDark = Color(0xFF0B2E21); // forest green gelap
  static const Color primaryDeep = Color(0xFF14513B); // forest menengah

  // Aksen mewah
  static const Color gold = Color(0xFFD9BC7A); // champagne gold
  static const Color goldSoft = Color(0xFFF1E4BF);

  // ---------------------------------------------------------------------
  // Background dan kartu (tema terang)
  // ---------------------------------------------------------------------
  static const Color background = Color(0xFFF3F8F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0EBE5);

  // ---------------------------------------------------------------------
  // Latar gelap (splash, onboarding, kartu premium)
  // ---------------------------------------------------------------------
  static const Color darkTop = Color(0xFF0B2E21);
  static const Color darkMid = Color(0xFF04140E);
  static const Color darkBottom = Color(0xFF020A07);
  static const Color onDarkMuted = Color(0xFFB7CFC3);
  static const Color onDarkDim = Color(0xFF6E8F7F);

  // ---------------------------------------------------------------------
  // Status keamanan kabin
  // ---------------------------------------------------------------------
  static const Color safe = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // ---------------------------------------------------------------------
  // Informasi dan teks
  // ---------------------------------------------------------------------
  static const Color info = Color(0xFF2196F3);
  static const Color textPrimary = Color(0xFF0F2A20);
  static const Color textSecondary = Color(0xFF6B8579);

  // ---------------------------------------------------------------------
  // Status perangkat
  // ---------------------------------------------------------------------
  static const Color online = Color(0xFF10B981);
  static const Color offline = Color(0xFF94A3B8);

  // ---------------------------------------------------------------------
  // Gradasi siap pakai
  // ---------------------------------------------------------------------
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkTop, darkMid, darkBottom],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF0B8F65)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [primaryLight, gold],
  );
}