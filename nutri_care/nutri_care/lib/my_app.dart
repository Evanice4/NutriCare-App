import 'package:flutter/material.dart';
import 'screens/user_type_selection_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'NutriCare', home: _RootScreen());
  }
}

class _RootScreen extends StatefulWidget {
  @override
  State<_RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<_RootScreen> {
  String? _userType;

  @override
  Widget build(BuildContext context) {
    if (_userType == null) {
      return UserTypeSelectionScreen(
        onUserTypeSelected: (type) => setState(() => _userType = type),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Register or Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RegistrationScreen(userType: _userType!),
                  ),
                );
                if (result == true) setState(() => _userType = null);
              },
              child: const Text('Register'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
                if (result == true) setState(() => _userType = null);
              },
              child: const Text('Login'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => setState(() => _userType = null),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
