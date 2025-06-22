import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../requestConfig.dart';

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
    refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        loadLivingStatus();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> loadLivingStatus() async {
    try {
      final url = Uri.parse('$baseUrl/cat/living/status');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          livingData = data;
          connected = true;
        });
        print("[Living Room] Data updated: $livingData");
      } else {
        throw Exception("Failed to load living room status");
      }
    } catch (e) {
      print("HTTP error: $e");
      setState(() {
        connected = false;
      });
    }
  }

  Future<void> toggleDevice(String key, bool currentState) async {
    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No connection. Try again later.")),
      );
      return;
    }

    try {
      final url = Uri.parse('$baseUrl/cat/living/set');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({key: !currentState}),
      );

      if (response.statusCode == 200) {
        loadLivingStatus();
      } else {
        print("❌ Toggle failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error toggling $key: $e");
    }
    loadLivingStatus();
  }

  Future<void> triggerBuzzer() async {
    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No connection. Cannot trigger alert.")),
      );
      return;
    }

    try {
      final url = Uri.parse('$baseUrl/cat/living/buzzer');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'on'}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🚨 Emergency alert triggered!")),
        );
      } else {
        throw Exception("Failed to trigger buzzer");
      }
    } catch (e) {
      print("Emergency trigger error: $e");
    }
    loadLivingStatus();
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Widget _gridItem(IconData icon, String label, String value,
      {Color? color, Color? iconColor}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 28, color: iconColor ?? Colors.white),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade300,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
        final motion = connected ? (livingData["motion"] == true ? "Detected" : "None") : "N/A";
        final lights = connected ? (livingData["lightOn"] == true ? "On" : "Off") : "N/A";
        final emergencyOn = connected ? (livingData["emergencyOn"] == true ? "On" : "Off") : "N/A";
        final curtainOpen = connected ? (livingData["curtainOpen"] == true) : false;
        final fanOn = connected ? (livingData["fanOn"] == true) : false;
        final tvOn = connected ? (livingData["tvOn"] == true) : false;
        final temp = connected ? (livingData["temperature"]?.toString() ?? "N/A") : "N/A";
        final emergency = connected ? (livingData["emergencyOn"] == true ? "ACTIVE 🚨" : "No") : "N/A";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Living Room Dashboard"),
        backgroundColor: const Color(0xFF2879fe),
        elevation: 4,
      ),
      backgroundColor: const Color(0xFF10141c),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!connected)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "⚠️ No connection. Some data may be unavailable.",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

            // 🔲 Room Image
            Container(
              height: 160,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/living_room.jpg',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Text(
                      "Living Room",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📊 Status Panel
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _gridItem(Icons.directions_run, "Motion", motion,
                          iconColor: Colors.orange),
                      _gridItem(Icons.window, "Curtain",
                          curtainOpen ? "Open" : "Closed",
                          iconColor: Colors.blue),
                      _gridItem(Icons.thermostat, "Temp", "$temp°C",
                          iconColor: Colors.redAccent),
                      _gridItem(Icons.wind_power, "Fan",
                          fanOn ? "On" : "Off",
                          iconColor: Colors.teal),
                      _gridItem(Icons.tv, "TV", tvOn ? "On" : "Off",
                          iconColor: Colors.deepPurple),
                      _gridItem(
                        Icons.warning_amber_rounded,
                        "Emergency",
                        emergency,
                        color: emergency == "ACTIVE 🚨"
                            ? Colors.red
                            : Colors.green,
                        iconColor: emergency == "ACTIVE 🚨"
                            ? Colors.redAccent
                            : Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 🔘 Control Buttons
            ControlButton(
              label: lights == "On" ? "Turn Off Lights" : "Turn On Lights",
              icon: Icons.lightbulb,
              color: const Color(0xFF2879fe),
              onPressed: () => toggleDevice("lights", lights == "On"),
            ),
            const SizedBox(height: 16),
            ControlButton(
              label: curtainOpen ? "Close Curtain" : "Open Curtain",
              icon: Icons.window,
              color: const Color(0xFF2879fe),
              onPressed: () => toggleDevice("curtainOpen", curtainOpen),
            ),
            const SizedBox(height: 16),
            ControlButton(
              label: fanOn ? "Turn Off Fan" : "Turn On Fan",
              icon: Icons.wind_power,
              color: const Color(0xFF2879fe),
              onPressed: () => toggleDevice("fanOn", fanOn),
            ),
            const SizedBox(height: 16),
            ControlButton(
              label: tvOn ? "Turn Off TV" : "Turn On TV",
              icon: Icons.tv,
              color: const Color(0xFF2879fe),
              onPressed: () => toggleDevice("tvOn", tvOn),
            ),
            const SizedBox(height: 16),
            ControlButton(
              label: emergencyOn == "On" ? "Stop Emergency" : "Trigger Emergency Alert",
              icon: Icons.warning_amber_rounded,
              color: const Color(0xFF2879fe),
              onPressed: triggerBuzzer,
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
  final Color? iconColor;

  const ControlButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 6,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: iconColor ?? const Color(0xFF10141c)),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
