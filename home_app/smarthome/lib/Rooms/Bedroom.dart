import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class BedroomPage extends StatefulWidget {
  const BedroomPage({super.key});

  @override
  State<BedroomPage> createState() => _BedroomPageState();
}

class _BedroomPageState extends State<BedroomPage> {
  late IOWebSocketChannel channel;
  Map<String, dynamic> data = {};
  bool connected = false;

  @override
  void initState() {
    super.initState();
    connectWebSocket();
  }

  void connectWebSocket() {
    const socketUrl = 'ws://192.168.1.2:8080';
    channel = IOWebSocketChannel.connect(socketUrl);

    channel.stream.listen((message) {
      try {
        final parsed = jsonDecode(message);
        if (parsed.containsKey("living")) {
          setState(() {
            data = parsed["living"];
            connected = true;
          });
        }
      } catch (e) {
        print("WebSocket decode error: $e");
      }
    }, onError: (error) {
      print("WebSocket error: $error");
      setState(() => connected = false);
    }, onDone: () {
      setState(() => connected = false);
    });
  }

  void triggerBuzzer() {
    if (!connected) return;
    final message = jsonEncode({"command": "buzzer", "room": "living"});
    channel.sink.add(message);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Buzzer triggered")));
  }

  @override
  void dispose() {
    channel.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = data["motion"]?.toString() ?? "N/A";
    final light = data["light"]?.toString() ?? "N/A";

    return Scaffold(
      appBar: AppBar(title: const Text("Living Room Status"), backgroundColor: Colors.teal),
      backgroundColor: const Color(0xFF0d1017),
      body: connected
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                Card(
                  color: Colors.blueGrey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Living Room Sensors", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text("💡 Light: $light", style: const TextStyle(fontSize: 18)),
                        Text("🏃 Motion: $motion", style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: triggerBuzzer,
                  icon: const Icon(Icons.volume_up),
                  label: const Text("Trigger Buzzer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                )
              ]),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
