import 'package:flutter/material.dart';

class ChildNutritionScreen extends StatelessWidget {
  const ChildNutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/placeholder'),
            child: const Text("Skip", style: TextStyle(color: Colors.black)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.tealAccent,
              child: Icon(Icons.child_care_rounded, size: 60, color: Colors.brown),
            ),
            const SizedBox(height: 24),
            const Text(
              "Child Nutrition\nfocus",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Specialized guidance for children’s nutritional needs. Learn to prevent malnutrition and obesity with locally available, budget-friendly foods.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/placeholder');
              },
              child: const Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}
