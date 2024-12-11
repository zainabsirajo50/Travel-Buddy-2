import 'package:flutter/material.dart';

class BuddyProfileScreen extends StatelessWidget {
  final String buddyId;
  final String buddyName;
  final List<String> buddyInterests;

  const BuddyProfileScreen({
    required this.buddyId,
    required this.buddyName,
    required this.buddyInterests,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(buddyName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              buddyName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Interests: ${buddyInterests.join(', ')}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the chat screen to message the buddy
                Navigator.pushNamed(context, '/chat', arguments: buddyId);
              },
              child: const Text('Message Buddy'),
            ),
          ],
        ),
      ),
    );
  }
}
