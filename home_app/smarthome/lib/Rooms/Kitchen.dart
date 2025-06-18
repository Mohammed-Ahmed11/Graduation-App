import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

    // 🔁 Refresh data every 5 seconds
    refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        loadKitchenStatus();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> loadKitchenStatus() async {
    try {
      final url = Uri.parse('http://192.168.1.2:3001/cat/kitchen/status');
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
  try {
    final url = Uri.parse('http://192.168.1.2:3001/cat/kitchen/buzzer');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'action': 'on'}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Buzzer command sent!")),
      );
      print("[KitchenPage] Buzzer ON command sent");
    } else {
      print("[KitchenPage] Failed to send buzzer command: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: ${response.statusCode}")),
      );
    }
  } catch (e) {
    print("[KitchenPage] Error sending buzzer command: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("❌ Error: $e")),
    );
  }
}


  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alert = kitchenData["alert"] == true;
    final fire = kitchenData["fire"]?.toString() ?? "N/A";
    final mq2 = kitchenData["mq2"]?.toString() ?? "N/A";
    final mq5 = kitchenData["mq5"]?.toString() ?? "N/A";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitchen Status"),
        backgroundColor: const Color(0xFF2879fe),
      ),
      backgroundColor: const Color(0xFF0d1017),
      body: connected
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    color: alert ? const Color.fromARGB(255, 151, 55, 65) : Colors.green.shade100,
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
                            "Kitchen Sensors",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text("🔥 Fire: $fire", style: const TextStyle(fontSize: 18)),
                          Text("💨 MQ-2: $mq2%", style: const TextStyle(fontSize: 18)),
                          Text("🧪 MQ-5: $mq5%", style: const TextStyle(fontSize: 18)),
                          Text(
                            "⚠️ Alert: ${alert ? 'YES' : 'NO'}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: alert ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: triggerBuzzer,
                    icon: const Icon(Icons.warning),
                    label: const Text("Trigger Buzzer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    "Connecting to kitchen sensors...",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
    );
  }
}
