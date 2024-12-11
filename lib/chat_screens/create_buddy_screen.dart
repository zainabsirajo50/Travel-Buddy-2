import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'buddy_profile_detail.dart';  // Import BuddyProfileScreen

class CreateBuddyScreen extends StatefulWidget {
  @override
  _CreateBuddyScreenState createState() => _CreateBuddyScreenState();
}

class _CreateBuddyScreenState extends State<CreateBuddyScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<String> _interests = [
    'Hiking', 'Beach', 'Camping', 'City Tours', 'Adventure', 'Food',
    'Photography', 'History', 'Culture', 'Music'
  ];

  final List<String> _selectedInterests = [];

  TextEditingController _nameController = TextEditingController();

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  Future<void> _createProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Create a new profile with selected interests
    await _firestore.collection('travel_buddies').doc(userId).set({
      'name': _nameController.text,
      'interests': _selectedInterests,
    });

    // Navigate to BuddyProfileScreen with the user's profile info
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuddyProfileScreen(
          buddyId: userId, // Use the current user's ID
          buddyName: _nameController.text, // User's name from the input
          buddyInterests: _selectedInterests, // Pass the selected interests
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Travel Buddy Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Your Name'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select your interests:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Use Wrap with ChoiceChip for interests selection
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _interests.map((interest) {
                return ChoiceChip(
                  label: Text(interest),
                  selected: _selectedInterests.contains(interest),
                  onSelected: (_) => _toggleInterest(interest),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createProfile,
              child: const Text('Create Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
