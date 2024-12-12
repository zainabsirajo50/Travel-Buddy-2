import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_buddy_screen.dart'; 
import 'buddy_profile_detail.dart'; 

class BuddyMatchScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  BuddyMatchScreen({Key? key}) : super(key: key);

  Future<bool> _userHasProfile(String userId) async {
    final doc = await _firestore.collection('travel_buddies').doc(userId).get();
    return doc.exists;  // Returns true if profile exists
  }

  Future<List<DocumentSnapshot>> _findMatches(String userId) async {
    // Fetch the user's interests
    final doc = await _firestore.collection('travel_buddies').doc(userId).get();
    if (!doc.exists) return [];

    final userInterests = List<String>.from(doc['interests'] ?? []);
    
    // Query Firestore for users with matching interests
    final querySnapshot = await _firestore
        .collection('travel_buddies')
        .where('interests', arrayContainsAny: userInterests)
        .get();

    return querySnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Travel Buddy'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<bool>(
          future: currentUserId != null ? _userHasProfile(currentUserId) : Future.value(false),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == false) {
              // Show the create profile screen if the user doesn't have a profile
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Create your Travel Buddy profile to find potential matches!',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the create buddy profile screen
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

            // Fetch potential matches based on interests
            return FutureBuilder<List<DocumentSnapshot>>(
              future: currentUserId != null ? _findMatches(currentUserId) : Future.value([]),
              builder: (context, matchSnapshot) {
                if (matchSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!matchSnapshot.hasData || matchSnapshot.data!.isEmpty) {
                  // Show a message if no potential travel buddies are found
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No potential travel buddies found with similar interests.',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Navigate to the create buddy profile screen if no matches are found
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
                  children: matchSnapshot.data!.map((doc) {
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
            );
          },
        ),
      ),
    );
  }
}
