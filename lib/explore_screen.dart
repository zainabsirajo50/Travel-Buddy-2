import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacesService {
  final String apiKey = "AIzaSyBdwY7z9ENsJAy5yoRN9mj_VzfiC0VKxdE";  // Replace with your API Key
  final String baseUrl = "https://maps.googleapis.com/maps/api/place/nearbysearch/json";

  Future<List<dynamic>> getNearbyPlaces(double latitude, double longitude) async {
    final String url =
        "$baseUrl?location=$latitude,$longitude&radius=5000&type=restaurant&key=$apiKey"; // Adjust type as needed

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results']; // Assuming 'results' contains the list of places
    } else {
      throw Exception("Failed to load nearby places");
    }
  }
}

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final PlacesService _placesService = PlacesService();
  late GoogleMapController _mapController;
  final LatLng _center = const LatLng(37.7749, -122.4194); // Default location (San Francisco)
  List<dynamic> _places = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  // Default location is set to San Francisco
  late LatLng _currentLocation = _center;

  Set<Marker> _markers = Set<Marker>();  // Set to hold the markers for the places

  // Called when the map is created
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fetchNearbyPlaces(_currentLocation.latitude, _currentLocation.longitude);
  }

  // Fetch nearby places from PlacesService
  Future<void> _fetchNearbyPlaces(double latitude, double longitude) async {
    setState(() {
      _isLoading = true;
      _markers.clear();  // Clear existing markers
    });
    try {
      List<dynamic> places = await _placesService.getNearbyPlaces(latitude, longitude);

      setState(() {
        _places = places;
        _isLoading = false;
      });

      // Add a marker for each place
      for (var place in places) {
        final double lat = place['geometry']['location']['lat'];
        final double lng = place['geometry']['location']['lng'];
        final String name = place['name'];
        final String? address = place['vicinity'];

        _addNearbyMarker(lat, lng, name, address);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching nearby places: $e');
    }
  }

  // Add a marker for each nearby place
  void _addNearbyMarker(double lat, double lng, String name, String? address) {
    final Marker marker = Marker(
      markerId: MarkerId(name),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: name, snippet: address),
    );
    setState(() {
      _markers.add(marker);
    });
  }

  // Search location from the search bar
  Future<void> _searchLocation() async {
    if (_searchController.text.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(_searchController.text);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        setState(() {
          _currentLocation = LatLng(location.latitude, location.longitude);
        });
        _mapController.animateCamera(
          CameraUpdate.newLatLngZoom(_currentLocation, 12),
        );
        _fetchNearbyPlaces(_currentLocation.latitude, _currentLocation.longitude);
      } else {
        print("Location not found.");
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Nearby'),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for a place...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _searchLocation(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ],
            ),
          ),
          // Google Map
          Expanded(
            flex: 2,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers: _markers,
            ),
          ),
          // List of nearby places
          Expanded(
            flex: 1,
            child: _isLoading
                ? Center(child: CircularProgressIndicator()) // Show loading spinner
                : ListView.builder(
                    itemCount: _places.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_places[index]['name']),
                        subtitle: Text(_places[index]['vicinity'] ?? 'No address'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
