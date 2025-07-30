import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/child_nutrition_screen.dart';
import 'services/service_locator.dart';
import 'my_app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize services (dependency injection, etc.)
  serviceLocator.initialize();

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
        // Add more routes as needed, e.g.:
        // '/community_support': (context) => const CommunitySupportScreen(),
        // '/recipes': (context) => const RecipesScreen(),
      },
    );
  }
}
