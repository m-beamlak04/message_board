import 'package:cloud_firestore/cloud_firestore.dart';

import 'message.dart';

class BoardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // C - CREATE: Add a new message.
  Future<void> createMessage({
    required String text,
    required String authorUid,
    required String authorName,
  }) async {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      throw ArgumentError('Message cannot be empty.');
    }

    await _db.collection('messages').add({
      'text': trimmedText,
      'authorUid': authorUid,
      'authorName': authorName,
      'createdAt': FieldValue.serverTimestamp(),
      'editedAt': null,
    });
  }

  // R - READ: Listen for message changes in real time.
  Stream<List<Message>> watchMessages() {
    return _db.collection('messages').orderBy('createdAt').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        final createdAt = data['createdAt'] as Timestamp?;
        final editedAt = data['editedAt'] as Timestamp?;

        return Message(
          id: doc.id,
          text: data['text'] as String,
          authorUid: data['authorUid'] as String,
          authorName: data['authorName'] as String,
          createdAt: createdAt?.toDate(),
          editedAt: editedAt?.toDate(),
        );
      }).toList();
    });
  }

  // U - UPDATE: Edit an existing message.
  Future<void> updateMessage({
    required String messageId,
    required String text,
  }) async {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      throw ArgumentError('Message cannot be empty.');
    }

    await _db.collection('messages').doc(messageId).update({
      'text': trimmedText,
      'editedAt': FieldValue.serverTimestamp(),
    });
  }

  // D - DELETE: Remove an existing message.
  Future<void> deleteMessage(String messageId) async {
    await _db.collection('messages').doc(messageId).delete();
  }
}
