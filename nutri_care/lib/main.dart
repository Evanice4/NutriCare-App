import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'services/service_locator.dart';
import 'my_app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize services
  serviceLocator.initialize();

  runApp(const MyApp());
}
