import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  final TextEditingController _passwordController = TextEditingController();
  final List<String> _preferences = ['Beach', 'Mountains', 'City'];
  final List<String> _activities = ['Adventure', 'Culture', 'Relaxation'];

  List<String> selectedPreferences = [];
  List<String> selectedActivities = [];
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user!.uid).get();
        if (doc.exists) {
          setState(() {
            selectedPreferences =
                List<String>.from(doc.data()?['preferences'] ?? []);
            selectedActivities =
                List<String>.from(doc.data()?['activities'] ?? []);
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load preferences: $e')),
        );
      }
    }
  }

  Future<void> _savePreferences() async {
    if (user != null) {
      setState(() {
        isSaving = true;
      });
      try {
        await _firestore.collection('users').doc(user!.uid).set({
          'preferences': selectedPreferences,
          'activities': selectedActivities,
        }, SetOptions(merge: true));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Preferences saved successfully"),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to save preferences: $e"),
        ));
      } finally {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> _changePassword() async {
    if (_passwordController.text.isNotEmpty) {
      try {
        await user?.updatePassword(_passwordController.text);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Password changed successfully"),
        ));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Password change failed: $e"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter a new password"),
      ));
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Welcome, ${user?.email}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'Update Preferences',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _preferences.map((preference) {
                return FilterChip(
                  label: Text(preference),
                  selected: selectedPreferences.contains(preference),
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? selectedPreferences.add(preference)
                          : selectedPreferences.remove(preference);
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Activity Interests',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: _activities.map((activity) {
                return FilterChip(
                  label: Text(activity),
                  selected: selectedActivities.contains(activity),
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? selectedActivities.add(activity)
                          : selectedActivities.remove(activity);
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            isSaving
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _savePreferences,
                    child: Text('Save Preferences'),
                  ),
            SizedBox(height: 20),
            Divider(),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'New Password',
              ),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _changePassword,
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}