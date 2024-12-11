import 'package:flutter/material.dart';

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
            Image.network(destinationImageUrl),
            const SizedBox(height: 10),
            Text(
              destinationName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              destinationDescription,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Activities:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
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
