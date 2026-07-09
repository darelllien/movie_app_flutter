import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart'; // Sesuaikan path menuju file login_screen Anda

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  // Data konten untuk 3 Interaksi Onboarding
  final List<Map<String, dynamic>> onboardingData = [
    {
      "icon": Icons.movie_filter_rounded, // Interaksi 1: Discovery
      "title": "Temukan Film Favoritmu",
      "desc": "Jelajahi ribuan film terbaru dan klasik, semuanya ada dalam genggamanmu. Jangan ketinggalan hype-nya!",
    },
    {
      "icon": Icons.event_seat_rounded, // Interaksi 2: Ease of Use
      "title": "Pesan Tiket Tanpa Antre",
      "desc": "Pilih kursi terbaikmu, pesan tiket kapan saja, dan langsung masuk bioskop tanpa perlu antre di loket.",
    },
    {
      "icon": Icons.location_on_rounded, // Interaksi 3: Smart Experience
      "title": "Info Bioskop Terdekat",
      "desc": "Movix tahu bioskop mana yang paling dekat denganmu. Dapatkan jadwal tayang akurat setiap saat.",
    },
  ];

  // Fungsi saat onboarding selesai
  void _finishOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Tombol Skip (Lewati) di pojok kanan atas
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: Text(
                  'Lewati',
                  style: TextStyle(color: theme.colorScheme.primary),
                ),
              ),
            ),

            // PageView untuk konten yang bisa di-swipe
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ilustrasi / Ikon
                        // TIPS: Ganti Icon di bawah ini dengan Image.asset('assets/gambar1.png') jika Anda punya gambarnya
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            onboardingData[index]["icon"],
                            size: 120,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Judul
                        Text(
                          onboardingData[index]["title"],
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Sub-judul / Deskripsi
                        Text(
                          onboardingData[index]["desc"],
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

        Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: 50, // Memberikan tinggi agar Stack bisa memposisikan elemen dengan baik
            child: Stack(
              alignment: Alignment.center,
              children: [
              // Dot Indicators - Sekarang posisinya tepat di tengah (Center)
              Row(
              mainAxisSize: MainAxisSize.min, // Penting: agar Row tidak memenuhi seluruh lebar layar
              children: List.generate(
                onboardingData.length,
                    (index) => buildDotIndicator(index, theme),
              ),
            ),

            // Tombol "Selanjutnya" atau "Mulai Sekarang" - Dipaksa ke kanan (CenterRight)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage == onboardingData.length - 1) {
                    _finishOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  _currentPage == onboardingData.length - 1
                      ? 'Mulai'
                      : 'Lanjut',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
      )
    );
  }

  // Widget khusus untuk membuat titik indikator halaman
  Widget buildDotIndicator(int index, ThemeData theme) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? theme.colorScheme.primary
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}