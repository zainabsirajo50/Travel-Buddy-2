import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'edit-itinerary-screen.dart';

class ItineraryListScreen extends StatefulWidget {
  @override
  _ItineraryListScreenState createState() => _ItineraryListScreenState();
}

class _ItineraryListScreenState extends State<ItineraryListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> userPreferences = [];
  List<String> userActivities = [];
  double conversionRate = 1.0; // Default to 1.0 if no conversion is needed
  String selectedCurrency = "USD"; // Default currency

  @override
  void initState() {
    super.initState();
    _loadUserPreferences();
    _fetchConversionRate("USD", "EUR"); // Example: Convert USD to EUR
  }

  Future<void> _loadUserPreferences() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          userPreferences = List<String>.from(doc.data()?['preferences'] ?? []);
          userActivities = List<String>.from(doc.data()?['activities'] ?? []);
        });
      }
    }
  }

  Future<void> _fetchConversionRate(String fromCurrency, String toCurrency) async {
    final apiKey = "50be92f27a8503eb74928e77ade2de94"; 
    final url = "http://api.currencylayer.com/live?access_key=$apiKey&currencies=$toCurrency";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['quotes'];
        final rateKey = "${fromCurrency}$toCurrency";
        setState(() {
          conversionRate = rates[rateKey] ?? 1.0;
        });
      } else {
        throw Exception("Failed to load currency rates");
      }
    } catch (e) {
      print("Error fetching currency rate: $e");
    }
  }

  Future<List<DocumentSnapshot>> _getTailoredItineraries() async {
    QuerySnapshot querySnapshot = await _firestore.collection('itineraries').get();
    List<DocumentSnapshot> itineraries = querySnapshot.docs;

    if (userPreferences.isEmpty && userActivities.isEmpty) {
      return itineraries;
    }

    return itineraries.where((itinerary) {
      List<dynamic> itineraryPreferences = itinerary['preferences'] ?? [];
      List<dynamic> itineraryActivities = itinerary['activities'] ?? [];

      bool matchesPreferences = itineraryPreferences.any((pref) => userPreferences.contains(pref));
      bool matchesActivities = itineraryActivities.any((activity) => userActivities.contains(activity));

      return matchesPreferences || matchesActivities;
    }).toList();
  }

  void _navigateToItineraryDetails(DocumentSnapshot itinerary, double convertedBudget) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItineraryDetailsScreen(
          itinerary: itinerary,
          convertedBudget: convertedBudget,
          selectedCurrency: selectedCurrency,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tailored Itineraries"),
        actions: [
          DropdownButton<String>(
            value: selectedCurrency,
            items: ['USD', 'EUR', 'GBP'].map((currency) {
              return DropdownMenuItem(value: currency, child: Text(currency));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCurrency = value!;
              });
              _fetchConversionRate("USD", value!); // Convert USD to selected currency
            },
          ),
        ],
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _getTailoredItineraries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No itineraries available"));
          } else {
            List<DocumentSnapshot> itineraries = snapshot.data!;
            return ListView.builder(
              itemCount: itineraries.length,
              itemBuilder: (context, index) {
                var itinerary = itineraries[index];
                double originalBudget = itinerary['budget'] ?? 0.0;
                double convertedBudget = originalBudget * conversionRate;

                return Card(
                  margin: EdgeInsets.all(8),
                  elevation: 4,
                  child: ListTile(
                    title: Text(itinerary['title']),
                    subtitle: Text(
                      "${itinerary['description']}\nBudget: ${convertedBudget.toStringAsFixed(2)} $selectedCurrency",
                    ),
                    onTap: () => _navigateToItineraryDetails(itinerary, convertedBudget),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ItineraryDetailsScreen extends StatelessWidget {
  final DocumentSnapshot itinerary;
  final double convertedBudget;
  final String selectedCurrency;

  ItineraryDetailsScreen({
    required this.itinerary,
    required this.convertedBudget,
    required this.selectedCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(itinerary['title'])),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itinerary['description'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text("Budget: ${convertedBudget.toStringAsFixed(2)} $selectedCurrency"),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => EditItineraryScreen(itineraryId: itinerary.id),
  ),
);
              },
              child: Text("Edit Itinerary"),
            ),
          ],
        ),
      ),
    );
  }
}