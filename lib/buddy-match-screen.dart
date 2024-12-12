import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class BuddyMatchScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  BuddyMatchScreen({Key? key}) : super(key: key);
  User? user;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buddy Match'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchPotentialBuddies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No potential buddies found"));
          } else {
            List<DocumentSnapshot> buddies = snapshot.data!;
            return ListView.builder(
              itemCount: buddies.length,
              itemBuilder: (context, index) {
                var buddy = buddies[index];
                return ListTile(
                  title: Text('Buddy ID: ${buddy.id}'), // Displaying the document ID
                  subtitle: Text('Preferences: ${buddy['preferences']?.join(', ') ?? 'No interests listed'}'),
                  onTap: () {
                    // Navigate to the buddy details or messaging screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(buddyId: buddy.id), // Pass the doc ID to the chat screen
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> _fetchPotentialBuddies() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Query for users with similar interests (you can adjust this based on your matching logic)
      QuerySnapshot querySnapshot = await _firestore.collection('users').where('preferences', arrayContainsAny: ['Beach']).get();
      return querySnapshot.docs; // Return the list of documents
    } else {
      // Return an empty list if the user is not logged in
      return [];
    }
  }
}