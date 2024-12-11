import 'package:flutter/material.dart';

class CreateBuddyScreen extends StatelessWidget {
  const CreateBuddyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Travel Buddy'),
        centerTitle: true,
      ),
      body: Center(
        child: Text('This is the Create Buddy screen.'),
      ),
    );
  }
}
