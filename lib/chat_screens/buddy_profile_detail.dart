import 'package:flutter/material.dart';

class BuddyProfileScreen extends StatefulWidget {
  final String buddyId;
  final String buddyName;
  final List<String> buddyInterests;

  const BuddyProfileScreen({
    required this.buddyId,
    required this.buddyName,
    required this.buddyInterests,
    Key? key,
  }) : super(key: key);

  @override
  _BuddyProfileScreenState createState() => _BuddyProfileScreenState();
}

class _BuddyProfileScreenState extends State<BuddyProfileScreen> {
  List<String> selectedInterests = [];

  @override
  void initState() {
    super.initState();
    // Initialize selectedInterests with the buddy's interests
    selectedInterests = List.from(widget.buddyInterests);
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest); 
      } else {
        selectedInterests.add(interest);  
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.buddyName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Buddy's Name
            Text(
              widget.buddyName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // List of selectable interests (for filtering or adding new interests)
            const Text(
              'Your selected interests:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // List of possible interests (can be dynamic)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                'Hiking', 'Beach', 'Camping', 'City Tours', 'Adventure', 'Food',
    'Photography', 'History', 'Culture', 'Music'
              ]
                  .map((interest) => ChoiceChip(
                        label: Text(interest),
                        selected: selectedInterests.contains(interest),
                        onSelected: (_) => _toggleInterest(interest),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Message Buddy Button
            ElevatedButton(
              onPressed: () {
                // Navigate to the chat screen with the selected buddy and interests
                Navigator.pushNamed(
                  context,
                  '/chat',
                  arguments: {
                    'buddyId': widget.buddyId,
                    'buddyName': widget.buddyName,
                    'currentUserId': 'your_current_user_id', 
                    'selectedInterests': selectedInterests,
                  },
                );
              },
              child: const Text('Message Buddy'),
            ),
          ],
        ),
      ),
    );
  }
}
