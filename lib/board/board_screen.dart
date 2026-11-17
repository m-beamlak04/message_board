import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'board_service.dart';
import 'message.dart';
import '../auth/auth_service.dart';

class BoardScreen extends StatefulWidget {
  final User user;
  final String authorName;

  const BoardScreen({super.key, required this.user, required this.authorName});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final BoardService _boardService = BoardService();
  final TextEditingController _messageController = TextEditingController();
  final AuthService _authService = AuthService();

  late final Stream<List<Message>> _messagesStream;

  bool _posting = false;

  @override
  void initState() {
    super.initState();
    _messagesStream = _boardService.watchMessages();
  }

  Future<void> _postMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || _posting) return;

    setState(() => _posting = true);

    try {
      await _boardService.createMessage(
        text: text,
        authorUid: widget.user.uid,
        authorName: widget.authorName,
      );

      if (!mounted) return;
      _messageController.clear();
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not post message. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _posting = false);
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Board'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: _authService.signOut,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _messageController,
                  maxLines: 3,
                  minLines: 1,
                  decoration: const InputDecoration(
                    labelText: 'Write a message',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _posting ? null : _postMessage,
                    child: Text(_posting ? 'Posting...' : 'Post'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Could not load messages.'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Be the first to post!'),
                  );
                }

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];

                    return ListTile(
                      title: Text(message.authorName),
                      subtitle: Text(message.text),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
