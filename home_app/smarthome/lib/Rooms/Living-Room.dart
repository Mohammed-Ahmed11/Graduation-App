import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LivingRoomPage extends StatefulWidget {
  const LivingRoomPage({super.key});

  @override
  State<LivingRoomPage> createState() => _LivingRoomPageState();
}

class _LivingRoomPageState extends State<LivingRoomPage> {
  Map<String, dynamic> livingData = {};
  bool connected = false;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    loadLivingStatus();
    refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) loadLivingStatus();
    });
  }

  Future<void> loadLivingStatus() async {
    try {
      final url = Uri.parse('http://192.168.1.2:3001/cat/living/status');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        setState(() {
          livingData = jsonDecode(response.body);
          connected = true;
        });
      } else {
        throw Exception("Failed to load living room status");
      }
    } catch (e) {
      print("HTTP error: $e");
      setState(() => connected = false);
    }
  }

  Future<void> toggleDevice(String device, bool currentState) async {
    final url = Uri.parse('http://192.168.1.2:3001/cat/living/$device');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': currentState ? 'off' : 'on'}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ $device toggled successfully!")),
        );
        loadLivingStatus(); // refresh after change
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to toggle $device")),
        );
      }
    } catch (e) {
      print("[LivingRoomPage] Error toggling $device: $e");
    }
  }

  Future<void> triggerBuzzer() async {
    await toggleDevice("buzzer", false);
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = livingData["motion"] == true ? "Detected" : "None";
    final curtainOpen = livingData["curtainOpen"] == true;
    final fanOn = livingData["fanOn"] == true;
    final tvOn = livingData["tvOn"] == true;
    final temp = livingData["temperature"]?.toString() ?? "N/A";
    final emergency = livingData["emergencyOn"] == true ? "ACTIVE 🚨" : "No";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Living Room Status"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFF0d1017),
      body: connected
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Status Card
                  Card(
                    color: emergency == "ACTIVE 🚨"
                        ? const Color.fromARGB(255, 151, 55, 65)
                        : Colors.teal.shade100,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Living Room Sensors",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text("🏃 Motion: $motion", style: const TextStyle(fontSize: 18)),
                          Text("🪟 Curtain: ${curtainOpen ? "Open" : "Closed"}", style: const TextStyle(fontSize: 18)),
                          Text("🌡️ Temperature: $temp°C", style: const TextStyle(fontSize: 18)),
                          Text("🌀 Fan: ${fanOn ? "On" : "Off"}", style: const TextStyle(fontSize: 18)),
                          Text("📺 TV: ${tvOn ? "On" : "Off"}", style: const TextStyle(fontSize: 18)),
                          Text(
                            "🚨 Emergency: $emergency",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: emergency == "ACTIVE 🚨" ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Control Buttons
                  ControlButton(
                    label: curtainOpen ? "Close Curtain" : "Open Curtain",
                    icon: Icons.window,
                    color: Colors.orange,
                    onPressed: () => toggleDevice("curtain", curtainOpen),
                  ),
                  const SizedBox(height: 12),
                  ControlButton(
                    label: fanOn ? "Turn Off Fan" : "Turn On Fan",
                    icon: Icons.wind_power,
                    color: Colors.blue,
                    onPressed: () => toggleDevice("fan", fanOn),
                  ),
                  const SizedBox(height: 12),
                  ControlButton(
                    label: tvOn ? "Turn Off TV" : "Turn On TV",
                    icon: Icons.tv,
                    color: Colors.deepPurple,
                    onPressed: () => toggleDevice("tv", tvOn),
                  ),
                  const SizedBox(height: 12),
                  ControlButton(
                    label: "Trigger Emergency Alert",
                    icon: Icons.volume_up,
                    color: Colors.red,
                    onPressed: triggerBuzzer,
                  ),
                ],
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    "Connecting to living room sensors...",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
    );
  }
}

class ControlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const ControlButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontSize: 18),
      ),
      onPressed: onPressed,
    );
  }
}
