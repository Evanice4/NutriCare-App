import 'package:flutter/material.dart';

class UserTypeSelectionScreen extends StatelessWidget {
  final void Function(String userType) onUserTypeSelected;
  const UserTypeSelectionScreen({Key? key, required this.onUserTypeSelected})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select User Type')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => onUserTypeSelected('member'),
              child: const Text('Continue as Member'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => onUserTypeSelected('creator'),
              child: const Text('Continue as Creator (Nutritionist)'),
            ),
          ],
        ),
      ),
    );
  }
}
