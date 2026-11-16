import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserRecord(
    User user, {
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    await _db.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'role': role,
      'registrationDateTime': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserRecord(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchUserRecord(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }
}
