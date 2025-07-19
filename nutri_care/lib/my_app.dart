import 'package:flutter/material.dart';
import 'widgets/auth_wrapper.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriCare',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
