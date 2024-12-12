import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SavedItinerariesScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> _fetchSavedItineraries() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore
          .collection('user_itineraries')
          .doc(user.uid)
          .collection('itineraries')
          .get();
      return querySnapshot.docs;
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Saved Itineraries")),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchSavedItineraries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No saved itineraries found"));
          } else {
            List<DocumentSnapshot> itineraries = snapshot.data!;
            return ListView.builder(
              itemCount: itineraries.length,
              itemBuilder: (context, index) {
                var itinerary = itineraries[index];
                return ListTile(
                  title: Text(itinerary['title']),
                  subtitle: Text(itinerary['description']),
                );
              },
            );
          }
        },
      ),
    );
  }
}