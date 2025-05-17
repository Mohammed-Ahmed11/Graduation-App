import 'package:flutter/material.dart';
import 'package:smarthome/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'details_page.dart';
import 'main.dart'; // Import main page

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String username = "User"; // Default username
  String email = "email@gmail.com"; // Default username

  // Define categories with their corresponding images
  final List<Map<String, String>> categories = [
    {'title': 'Living Room', 'image': 'assets/images/living_room.jpg'},
    {'title': 'Kitchen', 'image': 'assets/images/kitchen.jpg'},
    {'title': 'Garage', 'image': 'assets/images/garage.jpg'},
    {'title': 'Roof', 'image': 'assets/images/roof.jpg'},
    {'title': 'Bedroom', 'image': 'assets/images/bedroom.jpg'},
    {'title': 'Garden', 'image': 'assets/images/garden.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      if (token.isNotEmpty) {
        // Extract username from token
        try {
          final parts = token.split('.');
          if (parts.length > 1) {
            // Base64Url decode with proper padding
            String base64Str = parts[1];
            // Add padding if needed
            while (base64Str.length % 4 != 0) {
              base64Str += '=';
            }

            final payload = utf8.decode(base64Url.decode(base64Str));
            final payloadMap = jsonDecode(payload);

            setState(() {
              username = payloadMap['username'] ?? 'User';
              email =  payloadMap['email'] ?? 'email@gmail.com';
            });
          }
        } catch (e) {
          print('Token parsing error: $e');
        }
      }
    } catch (e) {
      print('Failed to load username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1017), // Solid background color
      body: Column(
        children: [
          AppBar(
            backgroundColor: Color(0xFF2879fe),
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Hello, $username", // Using the extracted username
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "Weather Information",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Temperature: 25°C", style: TextStyle(color: Colors.black)),
                  Text("Humidity: 60%", style: TextStyle(color: Colors.black)),
                  Text("Wind Speed: 15 km/h", style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Your Rooms",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEEEEEE),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsPage(category: category),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              category['image']!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            color: Colors.black.withOpacity(0.5),
                          ),
                          Center(
                            child: Text(
                              category['title']!,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
        currentIndex: 1, // Set Categories as the selected tab
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 1) {
            // Stay on Categories page
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage(userData: {},)), // Profile Page Placeholder
            );
          }
        },
      ),
    );
  }
}