import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smarthome/main.dart' as main_app;
import 'package:smarthome/profile_page.dart';
import 'package:smarthome/Rooms/Living-Room.dart';
import 'package:smarthome/Rooms/Kitchen.dart';
import 'package:smarthome/Rooms/Garage.dart';
import 'package:smarthome/Rooms/Roof.dart';
import 'package:smarthome/Rooms/Bedroom.dart';
import 'package:smarthome/Rooms/Corridor.dart';
import 'package:smarthome/Rooms/Garden.dart';



class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String username = "User";
  String email = "email@gmail.com";

  String temperature = "--";
  String humidity = "--";
  String windSpeed = "--";

  final List<Map<String, String>> categories = [
    {'title': 'Living Room', 'image': 'assets/images/living_room.jpg'},
    {'title': 'Kitchen', 'image': 'assets/images/kitchen.jpg'},
    {'title': 'Garage', 'image': 'assets/images/garage.jpg'},
    {'title': 'Roof', 'image': 'assets/images/roof.jpg'},
    {'title': 'Bedroom', 'image': 'assets/images/bedroom.jpg'},
    {'title': 'Corridor', 'image': 'assets/images/corridor-2.png'},
    {'title': 'Garden', 'image': 'assets/images/garden.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _fetchWeather();
  }

  Future<void> _loadUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isNotEmpty) {
        final parts = token.split('.');
        if (parts.length > 1) {
          String base64Str = parts[1];
          while (base64Str.length % 4 != 0) base64Str += '=';
          final payload = utf8.decode(base64Url.decode(base64Str));
          final payloadMap = jsonDecode(payload);

          setState(() {
            username = payloadMap['username'] ?? 'User';
            email = payloadMap['email'] ?? 'email@gmail.com';
          });
        }
      }
    } catch (e) {
      print('Failed to load username: $e');
    }
  }

  Future<void> _fetchWeather() async {
    const apiKey = "78721b86b517b6b91d97f465361178e6"; // Replace with your key
    const city = "Cairo";
    final url = Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          temperature = "${data['main']['temp'].round()}°C";
          humidity = "${data['main']['humidity']}%";
          windSpeed = "${data['wind']['speed']} m/s";
        });
      }
    } catch (e) {
      print("Weather fetch error: $e");
    }
  }

  Widget _getRoomPage(String title) {
    switch (title) {
      case 'Living Room':
        return const LivingRoomPage();
      case 'Kitchen':
        return const KitchenPage();
      case 'Garage':
        return const GaragePage();
      case 'Roof':
        return const RoofPage();
      case 'Bedroom':
        return const BedroomPage();
      case 'Corridor':
        return const CorridorPage();
      case 'Garden':
        return const GardenPage();
      default:
        return const Scaffold(body: Center(child: Text("Room not found")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1017),
      body: Column(
        children: [
          AppBar(
            backgroundColor: const Color(0xFF2879fe),
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Hello, $username", style: const TextStyle(fontSize: 18, color: Colors.white)),
                const SizedBox(width: 10),
                const Icon(Icons.person, color: Colors.white),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: const DecorationImage(
                  image: AssetImage('assets/images/sky.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  const Text("Weather Information", style: TextStyle(fontSize: 20, color: Colors.black)),
                  const SizedBox(height: 10),
                  Text("Temperature: $temperature", style: const TextStyle(color: Colors.black)),
                  Text("Humidity: $humidity", style: const TextStyle(color: Colors.black)),
                  Text("Wind Speed: $windSpeed", style: const TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text("Your Rooms", style: TextStyle(fontSize: 25, color: Color(0xFFEEEEEE))),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      final page = _getRoomPage(category['title']!);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
                    },
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(category['image']!, fit: BoxFit.cover),
                          ),
                          Container(color: Colors.black.withOpacity(0.5)),
                          Center(child: Text(category['title']!, style: const TextStyle(fontSize: 24, color: Colors.white))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2879fe),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => main_app.HomePage()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage(userData: {})));
          }
        },
      ),
    );
  }
}
