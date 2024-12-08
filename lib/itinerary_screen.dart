import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({Key? key}) : super(key: key);

  @override
  _ItineraryScreenState createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final CollectionReference _itinerariesCollection =
      FirebaseFirestore.instance.collection('itineraries');

  Future<void> _addItinerary() async {
    if (_destinationController.text.isNotEmpty &&
        _activityController.text.isNotEmpty) {
      await _itinerariesCollection.add({
        'destination': _destinationController.text,
        'activities': [_activityController.text],
        'timestamp': FieldValue.serverTimestamp(),
      });
      _destinationController.clear();
      _activityController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields')),
      );
    }
  }

  Future<void> _updateItinerary(String id, List<String> activities) async {
    await _itinerariesCollection.doc(id).update({'activities': activities});
  }

  Future<void> _deleteItinerary(String id) async {
    await _itinerariesCollection.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary Planner'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(labelText: 'Destination'),
                ),
                TextField(
                  controller: _activityController,
                  decoration: const InputDecoration(labelText: 'Activity'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addItinerary,
                  child: const Text('Add Itinerary'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _itinerariesCollection
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No itineraries available.'));
                }
                return ListView(
                  children: snapshot.data!.docs.map((document) {
                    final data = document.data() as Map<String, dynamic>;
                    final id = document.id;
                    final destination = data['destination'] ?? 'Unknown';
                    final activities =
                        List<String>.from(data['activities'] ?? []);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: ExpansionTile(
                        title: Text(destination),
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...activities.map((activity) => ListTile(
                                    title: Text(activity),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          activities.remove(activity);
                                          _updateItinerary(id, activities);
                                        });
                                      },
                                    ),
                                  )),
                              ListTile(
                                title: TextField(
                                  decoration: const InputDecoration(
                                      labelText: 'Add Activity'),
                                  onSubmitted: (newActivity) {
                                    if (newActivity.isNotEmpty) {
                                      setState(() {
                                        activities.add(newActivity);
                                        _updateItinerary(id, activities);
                                      });
                                    }
                                  },
                                ),
                              ),
                              TextButton(
                                onPressed: () => _deleteItinerary(id),
                                child: const Text(
                                  'Delete Itinerary',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}