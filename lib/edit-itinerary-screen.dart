import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class EditItineraryScreen extends StatefulWidget {
  final String itineraryId;

  EditItineraryScreen({required this.itineraryId});

  @override
  _EditItineraryScreenState createState() => _EditItineraryScreenState();
}

class _EditItineraryScreenState extends State<EditItineraryScreen> {
  Map<String, dynamic> itineraryData = {};
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController activitiesController = TextEditingController();
  List<String> activities = [];

  @override
  void initState() {
    super.initState();
    _fetchItineraryData();
  }

  // Fetch the current itinerary data
  Future<void> _fetchItineraryData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var docSnapshot = await FirebaseFirestore.instance
            .collection('itineraries')
            .doc(widget.itineraryId)
            .get();

        if (docSnapshot.exists) {
          setState(() {
            itineraryData = docSnapshot.data() as Map<String, dynamic>;
            titleController.text = itineraryData['title'] ?? '';
            descriptionController.text = itineraryData['description'] ?? '';
            budgetController.text = itineraryData['budget']?.toString() ?? '';
            activities = List<String>.from(itineraryData['activities'] ?? []);
            activitiesController.text = activities.join(', '); // Display current activities as comma-separated string
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Itinerary not found')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching itinerary: $e')),
      );
    }
  }

  // Save the edited itinerary as a new document
  Future<void> _saveItineraryChanges() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var newItineraryRef = FirebaseFirestore.instance
            .collection('user_itineraries')
            .doc(user.uid)
            .collection('itineraries')
            .doc(); // Create a new document

        await newItineraryRef.set({
          'title': titleController.text,
          'description': descriptionController.text,
          'budget': double.tryParse(budgetController.text) ?? 0.0,
          'activities': activities,
          // Add other fields as necessary
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Itinerary saved successfully')),
        );

        // Optionally, you can navigate back to the previous screen after saving
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving itinerary: $e')),
      );
    }
  }

  Future<void> _addToUserItineraries() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      // Create a reference to the 'user_itineraries' subcollection
      var newItineraryRef = FirebaseFirestore.instance
          .collection('user_itineraries')
          .doc(user.uid)
          .collection('itineraries')
          .add({
        'title': titleController.text,
        'description': descriptionController.text,
        'budget': double.tryParse(budgetController.text) ?? 0.0,
        'activities': activities,
        // Add other fields you want to save
      });

      // Wait for the document to be added
      await newItineraryRef;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Itinerary added to your list!')),
      );

      // Optionally, navigate back or clear fields
      Navigator.pop(context);
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add itinerary: $e')),
      );
    }
  } else {
    // User not logged in
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User not logged in.')),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Itinerary"),
      ),
      body: itineraryData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Budget',
                    ),
                  ),
                  SizedBox(height: 8),
                 
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveItineraryChanges,
                    child: Text('Save Changes'),
                    style: ElevatedButton.styleFrom(

                    ),
                  ),
                ],
              ),
            ),
    );
  }
}