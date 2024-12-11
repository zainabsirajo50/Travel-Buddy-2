import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String buddyId;

  ChatScreen({Key? key, required this.buddyId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Buddy'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('Chat with buddy $buddyId here...'), // Implement your chat UI here
      ),
    );
  }
}
