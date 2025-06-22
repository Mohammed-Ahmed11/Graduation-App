import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../requestConfig.dart';
class GardenPage extends StatefulWidget {
  const GardenPage({super.key});

  @override
  State<GardenPage> createState() => _GardenPageState();
}

class _GardenPageState extends State<GardenPage> {
  Map<String, dynamic> gardenData = {};
  bool connected = false;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    loadGardenStatus();

    refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        loadGardenStatus();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> loadGardenStatus() async {
    try {
      final url = Uri.parse('$baseUrl/cat/garden/status');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          gardenData = data;
          connected = true;
        });
        print("[Garden] Data updated: $gardenData");
      } else {
        throw Exception("Failed to load garden status");
      }
    } catch (e) {
      print("Garden HTTP error: $e");
      setState(() => connected = false);
    }
  }

  Future<void> triggerSprinkler() async {
    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No connection. Cannot control sprinkler.")),
      );
      return;
    }

    try {
      final url = Uri.parse('$baseUrl/cat/garden/sprinkler');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'on'}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Sprinkler activated!")),
        );
      } else {
        throw Exception("Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Garden Sprinkler error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
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
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final temperature = connected ? "${gardenData["temperature"] ?? "N/A"}°C" : "N/A";
    final sunlight = connected ? "${gardenData["sunlight"] ?? "N/A"} lux" : "N/A";
    final soilMoisture = connected ? "${gardenData["soilMoisture"] ?? "N/A"}%" : "N/A";
    final humidity = connected ? "${gardenData["humidity"] ?? "N/A"}%" : "N/A";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Garden Dashboard"),
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

            // 🌿 Garden Image Banner
            Container(
              height: 160,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/garden.jpg',
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
                  const Positioned(
                    left: 16,
                    bottom: 16,
                    child: Text(
                      "Garden",
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

            // 🌾 Sensor Display
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
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _gridItem(Icons.thermostat, "Temperature", temperature,
                          iconColor: Colors.redAccent),
                      _gridItem(Icons.opacity, "Soil Moisture", soilMoisture,
                          iconColor: Colors.teal),
                      _gridItem(Icons.light_mode, "Sunlight", sunlight,
                          iconColor: Colors.yellow),
                      _gridItem(Icons.water_drop, "Humidity", humidity,
                          iconColor: Colors.blueAccent),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 💧 Sprinkler Button
            ControlButton(
              label: "Activate Sprinkler",
              icon: Icons.spa,
              color: Colors.green,
              onPressed: triggerSprinkler,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: iconColor ?? const Color(0xFF10141c)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
