import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class DetailsPage extends StatefulWidget {
  final Map<String, String> category;

  const DetailsPage({super.key, required this.category});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late List<Map<String, dynamic>> categoryDetails;
  late Timer? _updateTimer;

  // Using localhost:3001 as specified
  final String baseUrl = 'http://localhost:3001';

  final Map<String, List<String>> initialDetails = {
    'Living Room': ['Lights', 'TV', 'AC', 'Curtains'],
    'Kitchen': ['Smart Oven', 'Refrigerator Monitoring', 'Dishwasher Control'],
    'Garage': ['Automatic Door', 'Lights', 'Car Charging'],
    'Roof': ['Solar Panels', 'Water Drainage System'],
    'Bedroom': ['Smart Alarm', 'Air Purifier', 'Lighting Control'],
    'Garden': ['Automated Watering', 'Soil Monitoring', 'Outdoor Lighting'],
  };

  final Map<String, IconData> featureIcons = {
    'Lights': Icons.lightbulb_outline,
    'TV': Icons.tv,
    'AC': Icons.ac_unit,
    'Curtains': Icons.curtains,
    'Smart Oven': Icons.kitchen,
    'Refrigerator Monitoring': Icons.kitchen,
    'Dishwasher Control': Icons.water_drop_outlined,
    'Automatic Door': Icons.door_front_door,
    'Security Cameras': Icons.videocam,
    'Car Charging': Icons.electric_car,
    'Solar Panels': Icons.solar_power,
    'Water Drainage System': Icons.water_drop,
    'Weather Monitoring': Icons.cloud,
    'Smart Bed': Icons.bed,
    'Smart Alarm': Icons.alarm,
    'Air Purifier': Icons.air,
    'Lighting Control': Icons.light_mode,
    'Automated Watering': Icons.water,
    'Soil Monitoring': Icons.eco,
    'Outdoor Lighting': Icons.outdoor_grill,
  };

  // Simulated state for each category
  // In a real application, this would be fetched from your backend
  final Map<String, Map<String, dynamic>> categoryState = {
    'Living Room': {'temperature': 24, 'electricity': 150},
    'Kitchen': {'temperature': 22, 'electricity': 200},
    'Garage': {'temperature': 18, 'electricity': 100},
    'Roof': {'temperature': 30, 'electricity': 80},
    'Bedroom': {'temperature': 21, 'electricity': 120},
    'Garden': {'temperature': 28, 'electricity': 50},
  };

  @override
  void initState() {
    super.initState();
    categoryDetails = (initialDetails[widget.category['title']] ?? [])
        .map((feature) => {'name': feature, 'enabled': false})
        .toList();

    // Setup timer for real-time updates if it's the Kitchen category
    if (widget.category['title'] == 'Kitchen') {
      _fetchKitchenStatus(); // Initial fetch
      _updateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        _fetchKitchenStatus();
      });
    }
  }

  @override
  void dispose() {
    // Cancel timer when the widget is disposed
    _updateTimer?.cancel();
    super.dispose();
  }

  // Function to fetch kitchen status from your Node.js backend
  Future<void> _fetchKitchenStatus() async {
    if (widget.category['title'] != 'Kitchen') return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cat/kitchen/status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          categoryState['Kitchen']?['temperature'] = data['temp'];
          categoryState['Kitchen']?['electricity'] = data['electricity'];
        });

        print('Kitchen status updated: ${data['temp']}°C, ${data['electricity']} kWh');
      } else {
        print('Failed to fetch kitchen status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching kitchen status: $e');
    }
  }

  void _toggleFeature(int index) {
    setState(() {
      categoryDetails[index]['enabled'] = !categoryDetails[index]['enabled'];
    });
  }

  void _addNewFeature() {
    TextEditingController featureController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Feature'),
        content: TextField(
          controller: featureController,
          decoration: InputDecoration(hintText: 'Enter feature name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              String newFeature = featureController.text.trim();
              if (newFeature.isNotEmpty) {
                setState(() {
                  categoryDetails.add({'name': newFeature, 'enabled': false});
                });
              }
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String categoryTitle = widget.category['title']!;
    Map<String, dynamic> currentState =
        categoryState[categoryTitle] ?? {'temperature': 0, 'electricity': 0};

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryTitle),
        backgroundColor: const Color(0xFF2879fe),
      ),
      body: Stack(
        children: [
          // **Category Image**
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(widget.category['image']!),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // **Blurred Status Box**
          Positioned(
            top: 240,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // Semi-transparent
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.thermostat, color: Colors.red, size: 30),
                          SizedBox(height: 5),
                          Text(
                            '${currentState['temperature']}°C',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text("Temperature", style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.white30,
                      ),
                      Column(
                        children: [
                          Icon(Icons.electric_bolt, color: Colors.yellow, size: 30),
                          SizedBox(height: 5),
                          Text(
                            '${currentState['electricity']} kWh',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text("Electricity Usage", style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // **Features List**
          Padding(
            padding: const EdgeInsets.only(top: 370),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Features:',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: categoryDetails.length,
                    itemBuilder: (context, index) {
                      String featureName = categoryDetails[index]['name'];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          leading: Icon(
                            featureIcons[featureName] ?? Icons.device_unknown,
                            color: Colors.blue,
                          ),
                          title: Text(featureName),
                          trailing: Switch(
                            value: categoryDetails[index]['enabled'],
                            onChanged: (value) => _toggleFeature(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewFeature,
        backgroundColor: Color(0xFF2879fe),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}