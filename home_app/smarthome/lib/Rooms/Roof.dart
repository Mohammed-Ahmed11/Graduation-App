import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RoofPage extends StatefulWidget {
  const RoofPage({super.key});

  @override
  State<RoofPage> createState() => _RoofPageState();
}

class _RoofPageState extends State<RoofPage> {
  Map<String, dynamic> roofData = {};
  bool connected = false;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    loadRoofStatus();

    // 🔁 Refresh every 5 seconds
    refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        loadRoofStatus();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> loadRoofStatus() async {
    try {
      final url = Uri.parse('http://192.168.1.2:3001/cat/roof/status');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          roofData = data;
          connected = true;
        });
        print("[Roof] Data updated: $roofData");
      } else {
        throw Exception("Failed to load roof status");
      }
    } catch (e) {
      print("HTTP error: $e");
      setState(() => connected = false);
    }
  }

  void triggerRoofCommand() {
    // Optional: implement POST request if needed to send commands
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Command sent to Roof (placeholder)")),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final temp = roofData["temperature"]?.toString() ?? "N/A";
    final electricity = roofData["electricity"]?.toString() ?? "N/A";
    final rain = roofData["rainDetected"] == true;
    final solarStatus = roofData["solarPanelStatus"]?.toString() ?? "Unknown";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Roof Status"),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: const Color(0xFF0d1017),
      body: connected
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    color: rain ? Colors.red.shade100 : Colors.blueGrey.shade100,
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
                            "Roof Sensors",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text("🌡 Temperature: $temp°C", style: const TextStyle(fontSize: 18)),
                          Text("⚡ Electricity: $electricity", style: const TextStyle(fontSize: 18)),
                          Text("🌧 Rain: ${rain ? 'Detected' : 'None'}", style: const TextStyle(fontSize: 18)),
                          Text("🔋 Solar Panel: $solarStatus", style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: triggerRoofCommand,
                    icon: const Icon(Icons.settings),
                    label: const Text("Send Command"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  )
                ],
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text("Connecting to roof sensors...", style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
    );
  }
}
