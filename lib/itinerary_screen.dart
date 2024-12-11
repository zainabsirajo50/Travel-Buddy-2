import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItineraryListScreen extends StatefulWidget {
  @override
  _ItineraryListScreenState createState() => _ItineraryListScreenState();
}

class _ItineraryListScreenState extends State<ItineraryListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> userPreferences = [];
  List<String> userActivities = [];

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userPreferences = List<String>.from(doc.data()?['preferences'] ?? []);
          userActivities = List<String>.from(doc.data()?['activities'] ?? []);
        });
      }
    }
  }

  Future<List<DocumentSnapshot>> _getTailoredItineraries() async {
    // Retrieve all itineraries from Firestore
    QuerySnapshot querySnapshot = await _firestore.collection('itineraries').get();
    List<DocumentSnapshot> itineraries = querySnapshot.docs;

    // If no preferences are saved, show all itineraries
    if (userPreferences.isEmpty && userActivities.isEmpty) {
      return itineraries;
    }

    // Filter itineraries based on user preferences and activities
    return itineraries.where((itinerary) {
      List<dynamic> itineraryPreferences = itinerary['preferences'] ?? [];
      List<dynamic> itineraryActivities = itinerary['activities'] ?? [];

      // Match preferences or activities (OR condition)
      bool matchesPreferences = itineraryPreferences.any((pref) => userPreferences.contains(pref));
      bool matchesActivities = itineraryActivities.any((activity) => userActivities.contains(activity));

      // If either preference or activity matches, show the itinerary
      return matchesPreferences || matchesActivities;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tailored Itineraries"),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getTailoredItineraries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No itineraries available"));
          } else {
            List<DocumentSnapshot> itineraries = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: itineraries.length,
                    itemBuilder: (context, index) {
                      var itinerary = itineraries[index];
                      return ListTile(
                        title: Text(itinerary['title']),
                        subtitle: Text(itinerary['description']),
                        onTap: () {
                          // Navigate to itinerary detail screen
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/explore');
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Explore Nearby'),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
