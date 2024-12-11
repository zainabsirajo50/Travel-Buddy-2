import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String buddyId;

  ChatScreen({required this.buddyId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    String chatId = _getChatId(widget.buddyId);

    User? currentUser = FirebaseAuth.instance.currentUser;
    String currentUserId = currentUser?.uid ?? 'unknown';
    String currentUserName = currentUser?.displayName ?? 'Anonymous';

    // Save the message with the sender's name and the current timestamp
    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': currentUserId, 
      'senderName': currentUserName, 
      'message': message,
      'timestamp': FieldValue.serverTimestamp(), 
    });

    _messageController.clear();
  }

  String _getChatId(String buddyId) {
    // Use a method to generate a unique chat ID for the two users
    // This ensures that both users access the same chat
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    return currentUserId.compareTo(buddyId) < 0
        ? '$currentUserId-$buddyId'
        : '$buddyId-$currentUserId';
  }

  @override
  Widget build(BuildContext context) {
    String chatId = _getChatId(widget.buddyId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(message['message']),
                      subtitle: Text('Sender: ${message['senderName']}'), // Display sender's name
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(labelText: 'Enter a message'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
