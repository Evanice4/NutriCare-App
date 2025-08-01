import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import screens here for routing
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/child_nutrition_screen.dart';
import 'screens/community_support_screen.dart';
import 'screens/user_type_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';

import 'widgets/auth_wrapper.dart';

import 'services/service_locator.dart';
import 'firebase_options.dart';
import 'bloc/navigation/navigation_bloc.dart';
import 'bloc/user/user_bloc.dart';
import 'bloc/content/content_bloc.dart';
import 'bloc/search/search_bloc.dart';
import 'bloc/theme/theme_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize services
  serviceLocator.initialize();

  runApp(const NutriCareApp());
}

class NutriCareApp extends StatelessWidget {
  const NutriCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc()..add(LoadTheme()),
        ),
        BlocProvider<UserBloc>(create: (context) => UserBloc()),
        BlocProvider<ContentBloc>(create: (context) => ContentBloc()),
        BlocProvider<SearchBloc>(
          create: (context) =>
              SearchBloc(contentBloc: context.read<ContentBloc>()),
        ),
        BlocProvider<NavigationBloc>(
          create: (context) => NavigationBloc(
            searchBloc: context.read<SearchBloc>(),
          ),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'NutriCare',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.green,
              scaffoldBackgroundColor: Colors.white,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.green,
              scaffoldBackgroundColor: Colors.grey[900],
              brightness: Brightness.dark,
            ),
            themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/welcome': (context) => const WelcomeScreen(),
              '/childNutrition': (context) => const ChildNutritionScreen(),
              '/communitySupport': (context) => const CommunitySupportScreen(),
              '/userTypeSelection': (context) => UserTypeSelectionScreen(
                onUserTypeSelected: (userType) {
                  if (userType == 'member') {
                    Navigator.pushNamed(context, '/register');
                  } else {
                    Navigator.pushNamed(context, '/registerCreator');
                  }
                },
              ),
              '/login': (context) => const LoginScreen(),
              '/register': (context) =>
                  const RegistrationScreen(userType: 'member'),
              '/registerCreator': (context) =>
                  const RegistrationScreen(userType: 'creator'),
              '/home': (context) => const AuthWrapper(),
              '/auth': (context) => const AuthWrapper(),
            },
          );
        },
      ),
    );
  }
}
