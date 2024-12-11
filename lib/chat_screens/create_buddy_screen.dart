import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'matched_buddies_screen.dart';

class CreateBuddyScreen extends StatefulWidget {
  @override
  _CreateBuddyScreenState createState() => _CreateBuddyScreenState();
}

class _CreateBuddyScreenState extends State<CreateBuddyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _interestsController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  Future<void> _saveBuddy() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final interests = _interestsController.text.trim().split(',');

      // Save the buddy profile
      final newBuddy = await _firestore.collection('travel_buddies').add({
        'name': name,
        'interests': interests,
      });

      // Find matching buddies
      final matchedBuddies = await _firestore
          .collection('travel_buddies')
          .where('interests', arrayContainsAny: interests)
          .get();

      final matchedBuddyList = matchedBuddies.docs
          .where((doc) => doc.id != newBuddy.id) 
          .toList();

      // Navigate to the matched buddies screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MatchedBuddiesScreen(matchedBuddies: matchedBuddyList),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Travel Buddy'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _interestsController,
                decoration: const InputDecoration(
                  labelText: 'Interests (comma-separated)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter at least one interest';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveBuddy,
                child: const Text('Save & Find Matches'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
