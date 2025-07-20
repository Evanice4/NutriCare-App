import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF009639), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
              child: Image.asset('assets/nutri_logo.jpg'),
            ),
            const SizedBox(height: 20),
            const Text(
              'NutriCare',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Nourishing communities with\nsmart nutrition choices',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700), // Yellow button
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pushNamed(context, '/welcome'),
              child: const Text("Start"),
            ),
          ],
        ),
      ),
    );
  }
}
