import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homepage_screen.dart';
import 'main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser; // Get the currently signed-in user
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
          content: Text("Password change failed: ${e.toString()}"),
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
  Navigator.of(context).pushReplacementNamed('/login'); // Use named route for LoginScreen
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, ${user?.email}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signOut,
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
