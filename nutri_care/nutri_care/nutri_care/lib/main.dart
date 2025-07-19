import 'package:flutter/material.dart';
import 'onboarding_screens/splash_screen.dart';
import 'onboarding_screens/welcome_screen.dart';
import 'onboarding_screens/child_nutrition_screen.dart';
import 'onboarding_screens/placeholder_screen.dart';

void main() {
  runApp(const NutriCareApp());
}

class NutriCareApp extends StatelessWidget {
  const NutriCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/childNutrition': (context) => const ChildNutritionScreen(),
        '/placeholder': (context) => const PlaceholderScreen(),
      },
    );
  }
}
