import 'dart:ui';
import 'package:flutter/material.dart';

class LivingRoomPage extends StatefulWidget {
  const LivingRoomPage({super.key});

  @override
  State<LivingRoomPage> createState() => _LivingRoomPageState();
}

class _LivingRoomPageState extends State<LivingRoomPage> {
  Map<String, dynamic> livingData = {
    "motion": true,
    "curtainOpen": false,
    "fanOn": true,
    "tvOn": false,
    "temperature": 24,
    "emergencyOn": false,
  };

  Future<void> toggleDevice(String device, bool currentState) async {
    setState(() {
      if (device == "curtain") {
        livingData["curtainOpen"] = !currentState;
      } else if (device == "fan") {
        livingData["fanOn"] = !currentState;
      } else if (device == "tv") {
        livingData["tvOn"] = !currentState;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ $device toggled (mock)!")),
    );
  }

  Future<void> triggerBuzzer() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("🚨 Emergency alert triggered (mock)!")),
    );
  }

  Widget _gridItem(IconData icon, String label, String value,
      {Color? color, Color? iconColor}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 28, color: iconColor ?? Colors.white), // 🎯
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
    final motion = livingData["motion"] == true ? "Detected" : "None";
    final curtainOpen = livingData["curtainOpen"] == true;
    final fanOn = livingData["fanOn"] == true;
    final tvOn = livingData["tvOn"] == true;
    final temp = livingData["temperature"]?.toString() ?? "N/A";
    final emergency = livingData["emergencyOn"] == true ? "ACTIVE 🚨" : "No";

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
            // Room image
            Container(
              // margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                        shadows: [
                          Shadow(color: Colors.black, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ⬇️ Frosted Glass STATUS CARD
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
                      _gridItem(
                        Icons.directions_run,
                        "Motion",
                        motion,
                        iconColor: Colors.orange,
                      ),
                      _gridItem(
                        Icons.window,
                        "Curtain",
                        curtainOpen ? "Open" : "Closed",
                        iconColor: Colors.blue,
                      ),
                      _gridItem(
                        Icons.thermostat,
                        "Temp",
                        "$temp°C",
                        iconColor: Colors.redAccent,
                      ),
                      _gridItem(
                        Icons.wind_power,
                        "Fan",
                        fanOn ? "On" : "Off",
                        iconColor: Colors.teal,
                      ),
                      _gridItem(
                        Icons.tv,
                        "TV",
                        tvOn ? "On" : "Off",
                        iconColor: Colors.deepPurple,
                      ),
                      _gridItem(
                        Icons.warning_amber_rounded,
                        "Emergency",
                        emergency,
                        color: emergency == "ACTIVE 🚨" ? Colors.red : Colors.green,
                        iconColor: emergency == "ACTIVE 🚨" ? Colors.redAccent : Colors.green,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // CONTROL BUTTONS
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ControlButton(
                    label: curtainOpen ? "Close Curtain" : "Open Curtain",
                    icon: Icons.window,
                    color: Color(0xFF2879fe),
                    onPressed: () => toggleDevice("curtain", curtainOpen),
                  ),
                  const SizedBox(height: 16),
                  ControlButton(
                    label: fanOn ? "Turn Off Fan" : "Turn On Fan",
                    icon: Icons.wind_power,
                    color: Color(0xFF2879fe),
                    // iconColor: Colors.greenAccent,
                    onPressed: () => toggleDevice("fan", fanOn),
                  ),
                  const SizedBox(height: 16),
                  ControlButton(
                    label: tvOn ? "Turn Off TV" : "Turn On TV",
                    icon: Icons.tv,
                    color: Color(0xFF2879fe),
                    onPressed: () => toggleDevice("tv", tvOn),
                  ),
                  const SizedBox(height: 16),
                  ControlButton(
                    label: "Trigger Emergency Alert",
                    icon: Icons.warning_amber_rounded,
                    color: Color(0xFF2879fe),
                    onPressed: triggerBuzzer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusItem(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.black87, size: 24),
        const SizedBox(width: 12),
        Text(
          "$label:",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.black,
          ),
        ),
      ],
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
      width: double.infinity, // ✅ Full screen width
      margin: const EdgeInsets.symmetric(horizontal: 20), // ✅ Padding on sides
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
          mainAxisAlignment: MainAxisAlignment.start, // ✅ Align to left
          children: [
            Icon(icon, size: 24, color: iconColor ?? const Color(0xFF10141c),),
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

