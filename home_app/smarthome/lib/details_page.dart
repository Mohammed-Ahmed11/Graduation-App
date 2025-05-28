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

  final Map<String, Map<String, dynamic>> categoryState = {
    'Living Room': {'temperature': 24, 'electricity': 150},
    'Kitchen': {'temperature': 22, 'electricity': 200},
    'Garage': {'temperature': 18, 'electricity': 100},
    'Roof': {'temperature': 30, 'electricity': 80},
    'Bedroom': {'temperature': 21, 'electricity': 120},
    'Garden': {'temperature': 28, 'electricity': 50},
  };

  int? expandedIndex;

  // Light strength per feature index (1 to 3)
  Map<int, int> lightStrengthLevels = {};

  // TV on/off times per feature index
  Map<int, TimeOfDay> tvOnTimes = {};
  Map<int, TimeOfDay> tvOffTimes = {};

  // AC levels (1 to 7) per feature index
  Map<int, int> acLevels = {};

  @override
  void initState() {
    super.initState();

    categoryDetails = (initialDetails[widget.category['title']] ?? [])
        .map((feature) => {'name': feature, 'enabled': false})
        .toList();

    // Initialize Lights levels to 1
    for (int i = 0; i < categoryDetails.length; i++) {
      if (categoryDetails[i]['name'] == 'Lights') {
        lightStrengthLevels[i] = 1;
      }
      if (categoryDetails[i]['name'] == 'TV') {
        // Default TV On time = now, Off time = now + 1 hour
        final now = TimeOfDay.now();
        tvOnTimes[i] = now;
        tvOffTimes[i] = TimeOfDay(
          hour: (now.hour + 1) % 24,
          minute: now.minute,
        );
      }
      if (categoryDetails[i]['name'] == 'AC') {
        acLevels[i] = 1; // default AC level 1 → 16°C
      }
    }

    if (widget.category['title'] == 'Kitchen') {
      _fetchKitchenStatus();
      _updateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
        _fetchKitchenStatus();
      });
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

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

  Future<TimeOfDay?> _pickTime(BuildContext context, TimeOfDay initialTime) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }

  Widget _buildFeatureDetails(int index) {
    final featureName = categoryDetails[index]['name'];

    if (featureName == 'Lights' && categoryDetails[index]['enabled']) {
      int currentLevel = lightStrengthLevels[index] ?? 1;
      return Padding(
        padding: const EdgeInsets.only(top: 12.0, left: 16, right: 16, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Light Level',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: currentLevel.toDouble(),
              min: 1,
              max: 3,
              divisions: 2,
              label: ['Low', 'Medium', 'High'][currentLevel - 1],
              onChanged: (double value) {
                setState(() {
                  lightStrengthLevels[index] = value.round();
                });
              },
            ),
          ],
        ),
      );
    }

    if (featureName == 'TV' && categoryDetails[index]['enabled']) {
      TimeOfDay onTime = tvOnTimes[index] ?? TimeOfDay.now();
      TimeOfDay offTime = tvOffTimes[index] ??
          TimeOfDay(hour: (onTime.hour + 1) % 24, minute: onTime.minute);

      // Check if current time is after offTime to simulate TV auto-off
      TimeOfDay now = TimeOfDay.now();

      bool isTvOn = _isTimeInRange(now, onTime, offTime);

      return Padding(
        padding: const EdgeInsets.only(top: 12.0, left: 16, right: 16, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TV Schedule',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('On Time: ${_formatTimeOfDay(onTime)}'),
                ElevatedButton(
                  onPressed: () async {
                    TimeOfDay? picked = await _pickTime(context, onTime);
                    if (picked != null) {
                      setState(() {
                        tvOnTimes[index] = picked;
                        // Adjust offTime if needed to keep order
                        if (!_isTimeInRange(tvOffTimes[index] ?? picked, picked, TimeOfDay(hour: 23, minute: 59))) {
                          tvOffTimes[index] = TimeOfDay(
                            hour: (picked.hour + 1) % 24,
                            minute: picked.minute,
                          );
                        }
                      });
                    }
                  },
                  child: Text('Set'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Off Time: ${_formatTimeOfDay(offTime)}'),
                ElevatedButton(
                  onPressed: () async {
                    TimeOfDay? picked = await _pickTime(context, offTime);
                    if (picked != null) {
                      setState(() {
                        tvOffTimes[index] = picked;
                      });
                    }
                  },
                  child: Text('Set'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'TV is currently: ${isTvOn ? 'ON' : 'OFF (Auto-off)'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isTvOn ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      );
    }

    if (featureName == 'AC' && categoryDetails[index]['enabled']) {
      int level = acLevels[index] ?? 1;

      // Map level to temperature (16,18,20,22,24,26,28)
      List<int> tempLevels = [16, 18, 20, 22, 24, 26, 28];
      int temperature = tempLevels[level - 1];

      return Padding(
        padding: const EdgeInsets.only(top: 12.0, left: 16, right: 16, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AC Temperature',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Slider(
              value: level.toDouble(),
              min: 1,
              max: 7,
              divisions: 6,
              label: '$temperature °C',
              onChanged: (double value) {
                setState(() {
                  acLevels[index] = value.round();
                });
              },
            ),
            Text('Current Temperature: $temperature °C'),
          ],
        ),
      );
    }

    // Default empty if no special controls
    return const SizedBox.shrink();
  }

  bool _isTimeInRange(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final currentMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes <= endMinutes) {
      // Normal range
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Range across midnight
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = tod.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
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

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                color: Colors.white.withOpacity(0),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 380),
                Expanded(
                  child: ListView.builder(
                    itemCount: categoryDetails.length,
                    itemBuilder: (context, index) {
                      final isExpanded = expandedIndex == index;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            expandedIndex = isExpanded ? null : index;
                          });
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      featureIcons[categoryDetails[index]['name']] ??
                                          Icons.device_unknown,
                                      size: 36,
                                      color: Colors.blueAccent,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        categoryDetails[index]['name'],
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: categoryDetails[index]['enabled']
                                            ? Colors.green.withOpacity(0.15)
                                            : Colors.red.withOpacity(0.15),
                                      ),
                                      child: Text(
                                        categoryDetails[index]['enabled'] ? 'ON' : 'OFF',
                                        style: TextStyle(
                                          color: categoryDetails[index]['enabled']
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton(
                                      onPressed: () => _toggleFeature(index),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: categoryDetails[index]['enabled']
                                            ? Colors.red
                                            : Colors.green,
                                        minimumSize: const Size(70, 30),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: Text(categoryDetails[index]['enabled'] ? 'OFF' : 'ON'),
                                    ),
                                  ],
                                ),
                                // Show expanded content if expanded
                                if (isExpanded) _buildFeatureDetails(index),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Add new feature button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Feature'),
                      onPressed: _addNewFeature,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2879fe),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// Note: This code assumes you have a backend server running at http://localhost:3001
// that can handle the /cat/kitchen/status endpoint for fetching kitchen status.