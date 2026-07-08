import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_page.dart';
import 'login_page.dart';
import '../main/main_page.dart'; // Sesuaikan path jika berbeda

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    // Simulasi waktu loading untuk splash screen
    await Future.delayed(const Duration(seconds: 2));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (isFirstTime) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OnboardingScreen()));
    } else if (isLoggedIn) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainPage()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan warna primary dari theme main.dart
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Icon(
          Icons.movie_creation,
          size: 100,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}