import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'itinerary_screen.dart';


class HomeScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Buddy'),
        centerTitle: true,
        actions: [
          // Profile icon
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to the profile screen
              Navigator.pushNamed(context, '/profile');
            },
          ),
          // Logout icon
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              // Handle logout logic here
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

            const Spacer(),
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

  // Featured Destinations Section
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
                  // Navigate to destination details page
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
                        // Displaying image
                        destination['image_url'] != null
                            ? Image.network(
                                destination['image_url'],
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox(height: 60), // If no image, space is left
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

  // Recent Itineraries Section
  Widget _buildRecentItineraries() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('itineraries')
            .orderBy('timestamp', descending: true)
            .snapshots(),
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

              // Handle Firestore timestamp and format it
              if (timestamp != null) {
                dateTime = timestamp.toDate();
              }

              return ListTile(
                title: Text(itinerary['destination'] ?? 'Unknown'),
                subtitle: Text(
                  'Planned for: ${dateTime != null ? DateFormat.yMMMd().add_jm().format(dateTime) : 'N/A'}',
                ),
                onTap: () {
                  // Navigate to itinerary details screen
                  Navigator.pushNamed(context, '/itineraryDetails', arguments: doc.id);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

   // Sign-out method
  Future<void> _signOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error signing out: $e')),
    );
  }
}
}

// Destination Details Screen (New page)
class DestinationDetailsScreen extends StatelessWidget {
  final String destinationId;
  final String destinationName;
  final String destinationDescription;
  final String destinationImageUrl;
  final List<String> destinationActivities;

  const DestinationDetailsScreen({
    required this.destinationId,
    required this.destinationName,
    required this.destinationDescription,
    required this.destinationImageUrl,
    required this.destinationActivities,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(destinationName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Image.network(destinationImageUrl),
            const SizedBox(height: 10),
            
            // Destination Name
            Text(
              destinationName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Destination Description
            Text(
              destinationDescription,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Activities Section
            const Text(
              'Activities:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Displaying activities
            if (destinationActivities.isNotEmpty)
              ...destinationActivities.map((activity) {
                return ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: Text(activity),
                );
              }).toList(),
            if (destinationActivities.isEmpty)
              const Text('No activities available for this destination.', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}