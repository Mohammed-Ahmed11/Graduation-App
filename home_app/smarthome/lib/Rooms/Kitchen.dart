import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../requestConfig.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> {
  Map<String, dynamic> kitchenData = {};
  bool connected = false;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    loadKitchenStatus();

    refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        loadKitchenStatus();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> loadKitchenStatus() async {
    try {
      final url = Uri.parse('$baseUrl/cat/kitchen/status');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          kitchenData = data;
          connected = true;
        });
        print("[Kitchen] Data updated: $kitchenData");
      } else {
        throw Exception("Failed to load kitchen status");
      }
    } catch (e) {
      print("HTTP error: $e");
      setState(() => connected = false);
    }
  }

  void triggerBuzzer() async {
    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ No connection. Cannot trigger alert.")),
      );
      return;
    }

    try {
      final url = Uri.parse('$baseUrl/cat/kitchen/buzzer');
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
    final alert = connected ? (kitchenData["alert"] == true) : false;
    final fire = connected ? (kitchenData["fire"]?.toString() ?? "N/A") : "N/A";
    final mq2 = connected ? (kitchenData["mq2"]?.toString() ?? "N/A") : "N/A";
    final mq5 = connected ? (kitchenData["mq5"]?.toString() ?? "N/A") : "N/A";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitchen Dashboard"),
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

            // Room image
            Container(
              height: 160,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/kitchen.jpg',
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
                      "Kitchen",
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

            // Status Panel
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
                      _gridItem(Icons.local_fire_department, "Fire", fire,
                          iconColor: Colors.red),
                      _gridItem(Icons.cloud, "MQ-2", "$mq2%",
                          iconColor: Colors.orange),
                      _gridItem(Icons.science, "MQ-5", "$mq5%",
                          iconColor: Colors.teal),
                      _gridItem(
                        Icons.warning_amber_rounded,
                        "Alert",
                        connected
                            ? (alert ? "YES" : "NO")
                            : "N/A",
                        color: alert ? Colors.red : Colors.green,
                        iconColor:
                            alert ? Colors.redAccent : Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Control Button
            ControlButton(
              label: "Trigger Emergency Alert",
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: iconColor ?? const Color(0xFF10141c)),
            const SizedBox(width: 12),
            Text(label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
