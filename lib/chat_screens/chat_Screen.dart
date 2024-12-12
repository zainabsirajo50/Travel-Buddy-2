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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _currentUserName = '';

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  void _getUserName() {
    User? currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.displayName != null) {
      setState(() {
        _currentUserName = currentUser.displayName!;
      });
    } else {
      setState(() {
        _currentUserName = 'Anonymous';  // Fallback if no display name is set
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    String chatId = _getChatId(widget.buddyId);
    User? currentUser = _auth.currentUser;
    String currentUserId = currentUser?.uid ?? 'unknown';

    try {
      // Save the message with the sender's name and the current timestamp
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': currentUserId,
        'senderName': _currentUserName,  // Use the fetched user name here
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      // Optionally show an error to the user
    }
  }

  String _getChatId(String buddyId) {
    // Use a method to generate a unique chat ID for the two users
    // This ensures that both users access the same chat
    String currentUserId = _auth.currentUser?.uid ?? 'unknown';
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
                    final isSender = message['senderId'] == _auth.currentUser?.uid;
                    final alignment = isSender ? MainAxisAlignment.end : MainAxisAlignment.start;
                    final color = isSender ? Colors.blue[200] : Colors.grey[200];

                    return Align(
                      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['senderName'] ?? 'Unknown',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(message['message']),
                          ],
                        ),
                      ),
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
