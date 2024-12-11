import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_buddy_screen.dart'; 
import 'buddy_profile_detail.dart'; 

class BuddyMatchScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BuddyMatchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Travel Buddy'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('travel_buddies').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              // Show a message and a button to create a new buddy profile
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No potential travel buddies available.',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the create buddy screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateBuddyScreen(),
                          ),
                        );
                      },
                      child: const Text('Create Travel Buddy Profile'),
                    ),
                  ],
                ),
              );
            }

            // List potential travel buddies if available
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                final buddy = doc.data() as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () {
                    // Navigate to buddy profile details
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuddyProfileScreen(
                          buddyId: doc.id,
                          buddyName: buddy['name'],
                          buddyInterests: List<String>.from(buddy['interests'] ?? []),
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(buddy['name'] ?? 'Unknown'),
                      subtitle: Text('Interests: ${buddy['interests'].join(', ')}'),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
