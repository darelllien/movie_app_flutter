import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_app/screens/auth/splash_screen.dart';
import 'constants/app_color.dart';
import 'constants/app_text_styles.dart';
import 'data/account_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await AccountData.initializeAdmin();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinema App',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,

        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.cta,
          surface: AppColors.surface,
        ),

        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          titleLarge: AppTextStyles.headingLarge,
          titleMedium: AppTextStyles.headingMedium,
          titleSmall: AppTextStyles.headingSmall,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelSmall: AppTextStyles.caption,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cta,
            foregroundColor: AppColors.textOnCta,
            textStyle: AppTextStyles.button,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
