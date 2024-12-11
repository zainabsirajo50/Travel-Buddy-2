import 'package:flutter/material.dart';
import 'chat_Screen.dart'; // Chat screen implementation
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchedBuddiesScreen extends StatelessWidget {
  final List<QueryDocumentSnapshot> matchedBuddies;

  MatchedBuddiesScreen({required this.matchedBuddies});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matched Buddies'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: matchedBuddies.length,
        itemBuilder: (context, index) {
          final buddy = matchedBuddies[index].data() as Map<String, dynamic>;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(buddy['name']),
              subtitle: Text('Interests: ${buddy['interests'].join(', ')}'),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(buddyId: matchedBuddies[index].id),
                    ),
                  );
                },
                child: const Text('Chat'),
              ),
            ),
          );
        },
      ),
    );
  }
}
