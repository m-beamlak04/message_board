import 'package:cloud_firestore/cloud_firestore.dart';

class BoardService {
  // C - CREATE: Add a new message.
  Future<void> createMessage({
    required String text,
    required String authorUid,
    required String authorName,
  }) {
    throw UnimplementedError();
  }

  // R - READ: Listen for message changes in real time.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchMessages() {
    throw UnimplementedError();
  }

  // U - UPDATE: Edit an existing message.
  Future<void> updateMessage({
    required String messageId,
    required String text,
  }) {
    throw UnimplementedError();
  }

  // D - DELETE: Remove an existing message.
  Future<void> deleteMessage(String messageId) {
    throw UnimplementedError();
  }
}
