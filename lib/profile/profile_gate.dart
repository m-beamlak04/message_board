import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/auth_service.dart';
import 'user_service.dart';
import 'complete_profile_screen.dart';
import '../board/board_screen.dart';

class ProfileGate extends StatefulWidget {
  final User user;

  const ProfileGate({super.key, required this.user});

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  final UserService _userService = UserService();
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _profileStream;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileStream = _userService.watchUserRecord(widget.user.uid);
  }

  void _retry() {
    setState(_loadProfile);
  }

  bool _isComplete(Map<String, dynamic>? data) {
    if (data == null) return false;

    for (final field in ['uid', 'firstName', 'lastName', 'role']) {
      final value = data[field];
      if (value is! String || value.trim().isEmpty) {
        return false;
      }
    }

    return data['uid'] == widget.user.uid &&
        data['registrationDateTime'] is Timestamp;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _profileStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return _statusScreen(
            'Could not load your profile.',
            'Check your connection or Firestore permissions.',
          );
        }

        final data = snapshot.data?.data();

        if (!_isComplete(data)) {
          return CompleteProfileScreen(
            user: widget.user,
            onProfileSaved: _retry,
          );
        }

        return BoardScreen(
          user: widget.user,
          authorName: '${data?['firstName']} ${data?['lastName']}',
        );
      },
    );
  }

  Widget _statusScreen(String title, String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message Board')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _retry, child: const Text('Retry')),
              TextButton(
                onPressed: () => AuthService().signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
