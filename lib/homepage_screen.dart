import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'destination_details_screen.dart';
import 'chat_screens/buddy_match_screen.dart';
import 'chat_screens/create_buddy_screen.dart';  
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Buddy'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Featured Destinations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildFeaturedDestinations(),

            const SizedBox(height: 20),

            const Text(
              'Recent Itineraries',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildRecentItineraries(),

            const SizedBox(height: 20),

            // Button to navigate to Buddy Match Screen or Create Profile if not created
            ElevatedButton(
              onPressed: () async {
                final userId = _auth.currentUser?.uid;

                if (userId != null) {
                  // Check if the user has already created a buddy profile
                  final buddyDoc = await _firestore.collection('travel_buddies').doc(userId).get();

                  if (buddyDoc.exists) {
                    // If the buddy profile exists, navigate to BuddyMatchScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BuddyMatchScreen()),  // Navigate to BuddyMatchScreen
                    );
                  } else {
                    // If the buddy profile does not exist, navigate to CreateBuddyScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateBuddyScreen()),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
              child: const Text('Find Buddy'),
            ),

            const SizedBox(height: 20),

            // Button for planning a new trip
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/itineraries');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
              ),
              child: const Text('Plan New Trip'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedDestinations() {
    return SizedBox(
      height: 150,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('featured_destinations').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No featured destinations available.'));
          }

          return ListView(
            scrollDirection: Axis.horizontal,
            children: snapshot.data!.docs.map((doc) {
              final destination = doc.data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DestinationDetailsScreen(
                        destinationId: doc.id,
                        destinationName: destination['name'],
                        destinationDescription: destination['description'],
                        destinationImageUrl: destination['image_url'],
                        destinationActivities: List<String>.from(destination['activities'] ?? []),
                      ),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(right: 10),
                  child: Container(
                    width: 120,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        destination['image_url'] != null
                            ? Image.network(destination['image_url'], height: 60, fit: BoxFit.cover)
                            : const SizedBox(height: 60),
                        const SizedBox(height: 10),
                        Text(
                          destination['name'] ?? 'Unknown',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildRecentItineraries() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('itineraries').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No recent itineraries.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final itinerary = doc.data() as Map<String, dynamic>;
              Timestamp? timestamp = itinerary['timestamp'];
              DateTime? dateTime;
              if (timestamp != null) {
                dateTime = timestamp.toDate();
              }

              return ListTile(
                title: Text(itinerary['destination'] ?? 'Unknown'),
                subtitle: Text('Planned for: ${dateTime != null ? DateFormat.yMMMd().add_jm().format(dateTime) : 'N/A'}'),
                onTap: () {
                  Navigator.pushNamed(context, '/itineraryDetails', arguments: doc.id);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
