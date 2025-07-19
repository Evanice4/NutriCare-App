import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationScreen extends StatefulWidget {
  final String userType;
  const RegistrationScreen({Key? key, required this.userType})
    : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  File? _certificateFile;
  bool _loading = false;
  String? _error;

  Future<void> _pickCertificate() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _certificateFile = File(picked.path);
      });
    }
  }

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _error = 'Passwords do not match';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;
      final storage = FirebaseStorage.instance;
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      String uid = userCredential.user!.uid;
      String? certificateUrl;
      if (widget.userType == 'creator' && _certificateFile != null) {
        final ref = storage.ref().child(
          'certificates/$uid/${_certificateFile!.path.split('/').last}',
        );
        await ref.putFile(_certificateFile!);
        certificateUrl = await ref.getDownloadURL();
      }
      await firestore.collection('users').doc(uid).set({
        'email': _emailController.text.trim(),
        'displayName': _displayNameController.text.trim(),
        'userType': widget.userType,
        'role': widget.userType == 'creator' ? 'creator' : 'member',
        'isVerified': widget.userType == 'creator' ? false : null,
        'certificateUrl': certificateUrl,
      });
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Register as ${widget.userType == 'creator' ? 'Creator' : 'Member'}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(labelText: 'Display Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || !v.contains('@')
                    ? 'Enter a valid email'
                    : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) =>
                    v == null || v.length < 6 ? 'Min 6 chars' : null,
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
                obscureText: true,
                validator: (v) => v != _passwordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
              if (widget.userType == 'creator') ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickCertificate,
                  child: Text(
                    _certificateFile == null
                        ? 'Upload Certificate'
                        : 'Certificate Selected',
                  ),
                ),
                if (_certificateFile != null)
                  Text('Selected: ${_certificateFile!.path.split('/').last}'),
              ],
              const SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _loading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) _register();
                      },
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
