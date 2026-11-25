
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/onboarding/pages/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartCarSafetyApp());
}

class SmartCarSafetyApp extends StatelessWidget {
  const SmartCarSafetyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Car Safety System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashPage(),
    );
  }
}
