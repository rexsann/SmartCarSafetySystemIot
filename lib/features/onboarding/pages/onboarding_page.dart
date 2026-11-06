import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../navigation/pages/main_navigation_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _items = [
    _OnboardingItem(
      image: 'assets/images/onboarding_car.jpg',
      tag: 'DETEKSI REAL-TIME',
      title: 'Deteksi CO\nSecara Real-time',
      description: 'Sensor gas mendeteksi kadar karbon '
          'monoksida di dalam kabin mobil secara langsung.',
      icon: Icons.sensors_rounded,
      accent: AppColors.primary,
    ),
    _OnboardingItem(
      image: 'assets/images/onboarding_phone.jpg',
      tag: 'PANTAU KAPAN SAJA',
      title: 'Pantau di Mana Saja',
      description: 'Data ditampilkan secara real-time, lengkap '
          'dengan riwayat kadar CO dan informasi peringatan.',
      icon: Icons.phone_iphone_rounded,
      accent: AppColors.info,
    ),
    _OnboardingItem(
      image: 'assets/images/onboarding_alarm.jpg',
      tag: 'PERINGATAN DINI',
      title: 'Alarm & Buzzer',
      description: 'Jika kadar CO melebihi batas aman, buzzer '
          'dan LED akan aktif secara otomatis. Anda juga '
          'bisa mematikan buzzer melalui aplikasi.',
      icon: Icons.notifications_active_rounded,
      accent: AppColors.warning,
    ),
    _OnboardingItem(
      image: 'assets/images/onboarding_success.jpg',
      tag: 'SIAP DIGUNAKAN',
      title: 'Siap Menjaga\nKeselamatan Anda',
      description: 'Sekarang Anda sudah siap menggunakan Smart Car Safety.',
      icon: Icons.verified_user_rounded,
      accent: AppColors.gold,
      contain: true,
    ),
  ];

  bool get _isLast => _currentPage == _items.length - 1;

  double get _page =>
      _controller.hasClients && _controller.position.haveDimensions
          ? (_controller.page ?? _currentPage.toDouble())
          : _currentPage.toDouble();

  void _nextPage() {
    if (!_isLast) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const MainNavigationPage()),
      );
    }
  }

  void _skip() {
    _controller.animateToPage(
      _items.length - 1,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _items[_currentPage].accent;

    return Scaffold(
      backgroundColor: AppColors.darkMid,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.darkGradient),
            ),
          ),
          // Cahaya lembut atas — warnanya mengikuti halaman
          Positioned(
            top: -110,
            right: -80,
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: accent),
              duration: const Duration(milliseconds: 600),
              builder: (context, color, _) {
                final c = color ?? accent;
                return Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        c.withValues(alpha: 0.26),
                        c.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Cahaya lembut bawah
          Positioned(
            bottom: -140,
            left: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          PageView.builder(
            controller: _controller,
            itemCount: _items.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) => _buildPage(_items[i], i),
          ),
          _buildTopBar(),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ───────────────────────── Halaman ─────────────────────────

  Widget _buildPage(_OnboardingItem item, int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final delta = (index - _page).clamp(-1.0, 1.0);
        final fade = (1 - delta.abs()).clamp(0.0, 1.0);
        final w = MediaQuery.sizeOf(context).width;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 68, bottom: 160),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Transform.translate(
                    offset: Offset(delta * w * 0.15, 0),
                    child: Opacity(
                      opacity: fade,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _ImageCard(item: item),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Transform.translate(
                  offset: Offset(delta * w * 0.3, 0),
                  child: Opacity(
                    opacity: fade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 14,
                                decoration: BoxDecoration(
                                  gradient: AppColors.goldGradient,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(index + 1).toString().padLeft(2, '0')}  •  ${item.tag}',
                                style: TextStyle(
                                  color: AppColors.gold.withValues(alpha: 0.95),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.6,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.description,
                            style: const TextStyle(
                              color: AppColors.onDarkMuted,
                              fontSize: 14.5,
                              height: 1.6,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ───────────────────────── Bar atas ─────────────────────────

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDeep, Color(0xFF062016)],
                  ),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.7),
                    width: 1.2,
                  ),
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.shield_rounded,
                      color: AppColors.primaryLight,
                      size: 27,
                    ),
                    Icon(
                      Icons.directions_car_rounded,
                      color: Colors.white,
                      size: 13,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Smart Car Safety',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _isLast ? 0 : 1,
                child: IgnorePointer(
                  ignoring: _isLast,
                  child: TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.onDarkMuted,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.14),
                        ),
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                    ),
                    child: const Text(
                      'Lewati',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Bar bawah ─────────────────────────

  Widget _buildBottomBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_items.length, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 28 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.gold
                          : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.45),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 22),
              _buildButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton() {
    final last = _isLast;
    final glow = last ? AppColors.gold : AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      height: 58,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: last
            ? AppColors.goldGradient
            : const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.38),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: _nextPage,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  last ? 'Mulai Sekarang' : 'Lanjut',
                  key: ValueKey(last),
                  style: TextStyle(
                    color: last ? AppColors.darkMid : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_rounded,
                color: last ? AppColors.darkMid : Colors.white,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Kartu gambar ─────────────────────────

class _ImageCard extends StatelessWidget {
  const _ImageCard({required this.item});

  final _OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDeep, Color(0xFF062016)],
        ),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: item.accent.withValues(alpha: 0.22),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: EdgeInsets.all(item.contain ? 20 : 0),
            child: Image.asset(
              item.image,
              fit: item.contain ? BoxFit.contain : BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => _Fallback(item: item),
            ),
          ),
          // Vinyet halus agar gambar menyatu dengan latar gelap
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.55, 1.0],
                  colors: [
                    Colors.transparent,
                    AppColors.darkMid.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tampil bila file gambar belum ada, agar layout tetap terlihat rapi.
class _Fallback extends StatelessWidget {
  const _Fallback({required this.item});

  final _OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: item.accent.withValues(alpha: 0.12),
          border: Border.all(color: item.accent.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: item.accent.withValues(alpha: 0.3),
              blurRadius: 40,
            ),
          ],
        ),
        child: Icon(item.icon, color: item.accent, size: 54),
      ),
    );
  }
}

class _OnboardingItem {
  final String image;
  final String tag;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final bool contain;

  const _OnboardingItem({
    required this.image,
    required this.tag,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    this.contain = false,
  });
}