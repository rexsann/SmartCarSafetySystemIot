import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../navigation/pages/main_navigation_page.dart';

// Bayangan tipis agar teks putih tetap terbaca di atas bagian gambar yang terang.
final List<Shadow> _textShadow = [
  Shadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 12),
];

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // alignY       : bagian gambar yang ditampilkan saat dipotong (-1 atas, 1 bawah).
  // heightFactor : tinggi gambar sebagai pecahan tinggi layar (1 = layar penuh).
  // fadeStart    : di mana gradasi gelap mulai muncul (0 = atas, 1 = bawah gambar).
  final List<_OnboardingItem> _items = [
    _OnboardingItem(
      image: 'assets/images/onboarding_car.jpg',
      tag: 'DETEKSI REAL-TIME',
      title: 'Deteksi CO\nSecara Real-time',
      description: 'Sensor gas mendeteksi kadar karbon '
          'monoksida di dalam kabin mobil secara langsung.',
      icon: Icons.sensors_rounded,
      accent: AppColors.primary,
      alignY: -0.1,
    ),
    _OnboardingItem(
      image: 'assets/images/onboarding_phone.jpg',
      tag: 'PANTAU KAPAN SAJA',
      title: 'Pantau di Mana Saja',
      description: 'Data ditampilkan secara real-time, lengkap '
          'dengan riwayat kadar CO dan informasi peringatan.',
      icon: Icons.phone_iphone_rounded,
      accent: AppColors.info,
      alignY: -0.5,
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
      alignY: 0.1,
    ),
    _OnboardingItem(
      image: 'assets/images/onboarding_success.jpg',
      tag: 'SIAP DIGUNAKAN',
      title: 'Siap Menjaga\nKeselamatan Anda',
      description: 'Sekarang Anda sudah siap menggunakan Smart Car Safety.',
      icon: Icons.verified_user_rounded,
      accent: AppColors.gold,
      alignY: 0,
      heightFactor: 0.62,
      fadeStart: 0.45,
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Muat semua gambar di awal supaya perpindahan halaman mulus.
    for (final item in _items) {
      precacheImage(AssetImage(item.image), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Latar polos yang sama dengan warna ujung gradasi gambar,
    // jadi gambar menyatu tanpa garis batas.
    return Scaffold(
      backgroundColor: AppColors.darkMid,
      body: Stack(
        children: [
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
        final size = MediaQuery.sizeOf(context);
        final bottomInset = MediaQuery.paddingOf(context).bottom;

        return Stack(
          children: [
            // Gambar sebagai latar, memenuhi bagian atas layar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: size.height * item.heightFactor,
              child: Opacity(
                opacity: (0.35 + 0.65 * fade).clamp(0.0, 1.0),
                child: _BackdropImage(item: item),
              ),
            ),
            // Teks di bagian bawah, di atas area gradasi
            Positioned(
              left: 0,
              right: 0,
              bottom: 150 + bottomInset,
              child: Transform.translate(
                offset: Offset(delta * size.width * 0.3, 0),
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
                                shadows: _textShadow,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            shadows: _textShadow,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.description,
                          style: TextStyle(
                            color: AppColors.onDarkMuted,
                            fontSize: 14.5,
                            height: 1.6,
                            letterSpacing: 0.1,
                            shadows: _textShadow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
                padding: const EdgeInsets.fromLTRB(5, 5, 14, 5),
                decoration: BoxDecoration(
                  color: AppColors.darkMid.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
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
                            size: 24,
                          ),
                          Icon(
                            Icons.directions_car_rounded,
                            color: Colors.white,
                            size: 11,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Smart Car Safety',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
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
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      backgroundColor: AppColors.darkMid.withValues(alpha: 0.45),
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
                          : Colors.white.withValues(alpha: 0.25),
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

// ───────────────────────── Gambar latar ─────────────────────────

/// Gambar penuh lebar tanpa bingkai. Gradasi gelap hanya ada di bagian bawah
/// (mulai dari [_OnboardingItem.fadeStart]), jadi bagian atas gambar tetap
/// bersih dan teks di bawah tetap terbaca.
class _BackdropImage extends StatelessWidget {
  const _BackdropImage({required this.item});

  final _OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.darkMid;
    final f = item.fadeStart;
    final span = 1 - f;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          item.image,
          fit: BoxFit.cover,
          alignment: Alignment(0, item.alignY),
          errorBuilder: (_, __, ___) => _Fallback(item: item),
        ),
        // Gradasi hanya ke bawah
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, f, f + span * 0.35, f + span * 0.7, 1.0],
                colors: [
                  bg.withValues(alpha: 0.0),
                  bg.withValues(alpha: 0.0),
                  bg.withValues(alpha: 0.62),
                  bg.withValues(alpha: 0.94),
                  bg,
                ],
              ),
            ),
          ),
        ),
      ],
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
  final double alignY;
  final double heightFactor;
  final double fadeStart;

  const _OnboardingItem({
    required this.image,
    required this.tag,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    this.alignY = 0,
    this.heightFactor = 1.0,
    this.fadeStart = 0.40,
  });
}