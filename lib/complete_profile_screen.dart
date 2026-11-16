import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'user_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  final User user;
  final VoidCallback onProfileSaved;

  const CompleteProfileScreen({
    super.key,
    required this.user,
    required this.onProfileSaved,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _userService = UserService();

  bool _busy = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_busy || !_formKey.currentState!.validate()) return;

    setState(() => _busy = true);

    try {
      await _userService.saveUserRecord(
        widget.user,
        firstName: _firstName.text,
        lastName: _lastName.text,
        role: 'user',
      );

      if (!mounted) return;
      widget.onProfileSaved();
    } on FirebaseException catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not save profile: ${error.message ?? error.code}',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Profile'),
        actions: [
          IconButton(
            onPressed: _busy ? null : () => AuthService().signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle, size: 72),
                const SizedBox(height: 16),
                Text(
                  'Finish setting up your account',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _firstName,
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter your first name'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastName,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter your last name'
                      : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _busy ? null : _saveProfile,
                  child: Text(_busy ? 'Saving...' : 'Save Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
