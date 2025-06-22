import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../requestConfig.dart';

class CorridorPage extends StatefulWidget {
  const CorridorPage({super.key});

  @override
  State<CorridorPage> createState() => _CorridorPageState();
}

class _CorridorPageState extends State<CorridorPage> {
  Map<String, dynamic> corridorData = {};
  bool connected = false;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    loadCorridorStatus();

    refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        loadCorridorStatus();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> loadCorridorStatus() async {
    try {
      final url = Uri.parse('$baseUrl/cat/corridor/status');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          corridorData = data;
          connected = true;
        });
        print("[Corridor] Data updated: $corridorData");
      } else {
        throw Exception("Failed to load corridor status");
      }
    } catch (e) {
      print("Corridor HTTP error: $e");
      setState(() => connected = false);
    }
  }

  Future<void> toggleLight() async {
  if (!connected) {
    _showSnack("⚠️ No connection. Cannot control light.");
    return;
  }

  final isOn = corridorData["light"] == true;
  final mode = isOn ? "off" : "on";

  try {
    final url = Uri.parse('$baseUrl/cat/corridor/light');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'mode': mode}),
    );

    if (response.statusCode == 200) {
      _showSnack("✅ Light turned ${isOn ? 'off' : 'on'}!");
    } else {
      throw Exception("Failed: ${response.statusCode}");
    }
  } catch (e) {
    print("Corridor Light error: $e");
    _showSnack("❌ Error: $e");
  }
  loadCorridorStatus(); // Refresh status after toggling
}

Future<void> toggleLock() async {
  if (!connected) {
    _showSnack("⚠️ No connection. Cannot control E-lock.");
    return;
  }

  final isLocked = corridorData["elock"] == true;
  final lockValue = !isLocked;

  try {
    final url = Uri.parse('$baseUrl/cat/corridor/elock');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'lock': lockValue}),
    );

    if (response.statusCode == 200) {
      _showSnack("🔒 E-lock ${lockValue ? 'locked' : 'unlocked'}");
    } else {
      throw Exception("Lock toggle failed: ${response.statusCode}");
    }
  } catch (e) {
    print("E-lock error: $e");
    _showSnack("❌ Error: $e");
  }
  loadCorridorStatus(); // Refresh status after toggling
}


  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
    final motion = connected
        ? (corridorData["motion"] == true ? "Detected" : "None")
        : "N/A";
    final light = connected
        ? (corridorData["light"] == true ? "On" : "Off")
        : "N/A";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Corridor"),
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

            // 🖼️ Image banner
            Container(
              height: 140,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/corridor.jpg',
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
                    bottom: 12,
                    child: Text(
                      "Corridor",
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

            // 🌫 Sensor Grid
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
                      _gridItem(Icons.directions_run, "Motion", motion,
                          iconColor: Colors.orange),
                      _gridItem(Icons.lightbulb, "Light", light,
                          iconColor: Colors.amber),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

           ControlButton(
            label: (corridorData["light"] == true) ? "Turn Off Light" : "Turn On Light",
            icon: (corridorData["light"] == true)
            ? Icons.lightbulb
            : Icons.lightbulb_outline,
            color: Colors.amber.shade700,
            onPressed: toggleLight,
            ),

          const SizedBox(height: 12),

          ControlButton(
            label: (corridorData["elock"] == true) ? "Unlock E-Lock" : "Lock E-Lock",
            icon: (corridorData["elock"] == true)
            ? Icons.lock_open
            : Icons.lock_outline,
            color: (corridorData["elock"] == true)
            ? Colors.green.shade600
            : Colors.red.shade600,
            onPressed: toggleLock,
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
