import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _ambientController;
  late final AnimationController _progressController;

  late final Animation<double> _logoAnim;
  late final Animation<double> _titleAnim;
  late final Animation<double> _featureAnim;
  late final Animation<double> _loaderAnim;
  late final Animation<double> _progress;

  // Palet diambil dari AppColors supaya konsisten di seluruh aplikasi
  static const Color bgTop = AppColors.darkTop;
  static const Color bgMid = AppColors.darkMid;
  static const Color bgBottom = AppColors.darkBottom;
  static const Color emerald = AppColors.primary;
  static const Color mint = AppColors.primaryLight;
  static const Color gold = AppColors.gold;
  static const Color textMuted = AppColors.onDarkMuted;
  static const Color textDim = AppColors.onDarkDim;

  static const List<String> _statusMessages = [
    'Menyiapkan sistem keamanan...',
    'Menghubungkan sensor CO...',
    'Mengaktifkan alarm otomatis...',
    'Sistem siap digunakan',
  ];

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    _logoAnim = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
    );
    _titleAnim = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic),
    );
    _featureAnim = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.45, 0.85, curve: Curves.easeOutCubic),
    );
    _loaderAnim = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    _progress = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    _introController.forward();
    _progressController.forward();

    _progressController.addStatusListener((status) async {
      if (status != AnimationStatus.completed) return;
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted) return;
      _goNext();
    });
  }

  void _goNext() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, secondaryAnimation) =>
            const OnboardingPage(),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 1.04, end: 1).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _introController.dispose();
    _ambientController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  // Fade + geser dari bawah
  Widget _reveal(Animation<double> anim, Widget child, {double dy = 24}) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        final v = anim.value.clamp(0.0, 1.0);
        return Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, (1 - v) * dy), child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgMid,
      body: Stack(
        children: [
          // Latar belakang gradasi hijau gelap
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [bgTop, bgMid, bgBottom],
                ),
              ),
            ),
          ),

          // Cahaya hijau bergerak lembut
          AnimatedBuilder(
            animation: _ambientController,
            builder: (context, child) {
              final t = _ambientController.value * 2 * math.pi;
              return Stack(
                children: [
                  Positioned(
                    top: -110 + 22 * math.sin(t),
                    right: -100,
                    child: _glowCircle(300, emerald),
                  ),
                  Positioned(
                    bottom: 60 + 28 * math.cos(t),
                    left: -140,
                    child: _glowCircle(300, emerald),
                  ),
                  Positioned(
                    top: 260 + 18 * math.cos(t),
                    left: -60 + 14 * math.sin(t),
                    child: _glowCircle(140, gold, strength: 0.07),
                  ),
                ],
              );
            },
          ),

          // Konten utama
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 26,
                          vertical: 24,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLogo(),
                            const SizedBox(height: 40),
                            _reveal(_titleAnim, _buildTitle()),
                            const SizedBox(height: 38),
                            _reveal(_featureAnim, _buildFeatures()),
                            const SizedBox(height: 46),
                            _reveal(_loaderAnim, _buildLoader(), dy: 14),
                            const SizedBox(height: 30),
                            FadeTransition(
                              opacity: _loaderAnim,
                              child: const Text(
                                'YOUR SAFETY IS OUR PRIORITY',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: textDim,
                                  fontSize: 9,
                                  letterSpacing: 2.4,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- LOGO

  Widget _buildLogo() {
    const double size = 150;
    return AnimatedBuilder(
      animation: Listenable.merge([_logoAnim, _ambientController]),
      builder: (context, _) {
        final appear = _logoAnim.value;
        final amb = _ambientController.value;

        return Opacity(
          opacity: appear.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.6 + 0.4 * appear,
            child: SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Gelombang denyut (ripple)
                  for (int i = 0; i < 2; i++) _ripple((amb + i * 0.5) % 1.0, size),

                  // Busur orbit berputar
                  Transform.rotate(
                    angle: amb * 2 * math.pi,
                    child: CustomPaint(
                      size: const Size(190, 190),
                      painter: _OrbitPainter(mint: mint, gold: gold),
                    ),
                  ),

                  // Lingkaran logo
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryDeep, Color(0xFF062016)],
                      ),
                      border: Border.all(
                        color: gold.withValues(alpha: 0.7),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: emerald.withValues(
                            alpha: 0.22 + 0.08 * math.sin(amb * 2 * math.pi),
                          ),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 124,
                          height: 124,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: mint.withValues(alpha: 0.18),
                              width: 1,
                            ),
                          ),
                        ),
                        const Icon(Icons.shield_rounded, color: mint, size: 100),
                        Transform.translate(
                          offset: Offset(0, 1.5 * math.sin(amb * 2 * math.pi)),
                          child: const Icon(
                            Icons.directions_car_rounded,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _ripple(double v, double base) {
    final d = base + v * 80;
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: emerald.withValues(alpha: (1 - v) * 0.28),
          width: 1.2,
        ),
      ),
    );
  }

  // --------------------------------------------------------------- TITLE

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'SMART CAR',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
          ),
        ),
        const SizedBox(height: 6),
        ShaderMask(
          shaderCallback: (rect) => const LinearGradient(
            colors: [mint, gold],
          ).createShader(rect),
          child: const Text(
            'SAFETY SYSTEM',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _goldLine(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Drive Safe, Live Better',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 13,
                  letterSpacing: 1.2,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            _goldLine(),
          ],
        ),
      ],
    );
  }

  Widget _goldLine() {
    return Container(
      width: 22,
      height: 1,
      color: gold.withValues(alpha: 0.6),
    );
  }

  // ------------------------------------------------------------ FEATURES

  Widget _buildFeatures() {
    return Row(
      children: [
        Expanded(child: _feature(Icons.air_rounded, 'Deteksi Gas CO')),
        const SizedBox(width: 10),
        Expanded(
          child: _feature(Icons.notifications_active_rounded, 'Alarm Otomatis'),
        ),
        const SizedBox(width: 10),
        Expanded(child: _feature(Icons.phone_android_rounded, 'Monitoring')),
      ],
    );
  }

  Widget _feature(IconData icon, String label) {
    return Container(
      height: 112,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.07),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.22)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: emerald.withValues(alpha: 0.12),
              border: Border.all(color: mint.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: mint, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- LOADER

  Widget _buildLoader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_progress, _ambientController]),
      builder: (context, _) {
        final p = _progress.value.clamp(0.0, 1.0);
        final idx = (p * _statusMessages.length)
            .floor()
            .clamp(0, _statusMessages.length - 1);

        return Column(
          children: [
            SizedBox(
              width: 240,
              height: 14,
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth;
                  final fillW = w * p;
                  return Stack(
                    alignment: Alignment.centerLeft,
                    clipBehavior: Clip.none,
                    children: [
                      // Track
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      // Isi progress + shimmer
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          width: fillW,
                          height: 4,
                          child: Stack(
                            children: [
                              const Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [emerald, mint, gold],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: FractionallySizedBox(
                                  alignment: Alignment(
                                    -1 + 2 * _ambientController.value * 3 % 2,
                                    0,
                                  ),
                                  widthFactor: 0.3,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withValues(alpha: 0),
                                          Colors.white.withValues(alpha: 0.55),
                                          Colors.white.withValues(alpha: 0),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Titik cahaya di ujung
                      Positioned(
                        left: (fillW - 6).clamp(0.0, w),
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: mint.withValues(alpha: 0.9),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                _statusMessages[idx],
                key: ValueKey<int>(idx),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textMuted,
                  fontSize: 12,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(p * 100).round()}%',
              style: TextStyle(
                color: gold.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _glowCircle(double size, Color color, {double strength = 0.2}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: strength),
            color.withValues(alpha: strength * 0.2),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

/// Busur orbit dengan gradasi hijau -> emas
class _OrbitPainter extends CustomPainter {
  _OrbitPainter({required this.mint, required this.gold});

  final Color mint;
  final Color gold;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          mint.withValues(alpha: 0),
          mint.withValues(alpha: 0.9),
          gold,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(rect);

    canvas.drawArc(rect.deflate(1), 0, math.pi * 1.2, false, paint);

    // Titik kecil di ujung busur
    final end = math.pi * 1.2;
    final center = size.center(Offset.zero);
    final r = size.width / 2 - 1;
    final dot = Offset(
      center.dx + r * math.cos(end),
      center.dy + r * math.sin(end),
    );
    canvas.drawCircle(dot, 3.5, Paint()..color = gold);
    canvas.drawCircle(
      dot,
      7,
      Paint()..color = gold.withValues(alpha: 0.25),
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => false;
}