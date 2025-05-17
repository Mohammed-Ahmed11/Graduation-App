import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smarthome/EditProfilePage.dart';
import 'package:smarthome/category_page.dart';
import 'package:smarthome/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final Map<String, String?> userData;

  const ProfilePage({super.key, required this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "User";
  String email = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      if (token.isNotEmpty) {
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
              username = payloadMap['username'] ?? widget.userData['fullName'] ?? 'User';
              email = payloadMap['email'] ?? widget.userData['email'] ?? 'user@example.com';
            });
          }
        } catch (e) {
          print('Token parsing error: $e');
        }
      }
    } catch (e) {
      print('Failed to load user data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1017), // Dark background matching app theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF2879fe),
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF2879fe)),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2879fe), Color(0xFF1c5fce)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: widget.userData['imagePath'] != null
                        ? FileImage(File(widget.userData['imagePath']!))
                        : const AssetImage('assets/images/profile.png') as ImageProvider,
                    backgroundColor: Colors.grey[800],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.userData['fullName'] ?? username,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.userData['email'] ?? email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Account Information",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEEEEEE),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.grey[900],
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          ProfileItem(
                            icon: Icons.person,
                            title: "Name",
                            value: widget.userData['fullName'] ?? username,
                          ),
                          Divider(thickness: 1, color: Colors.grey[800]),
                          ProfileItem(
                            icon: Icons.email,
                            title: "Email",
                            value: widget.userData['email'] ?? email,
                          ),
                          Divider(thickness: 1, color: Colors.grey[800]),
                          ProfileItem(
                            icon: Icons.phone,
                            title: "Phone",
                            value: widget.userData['phone'] ?? "Add phone number",
                          ),
                          Divider(thickness: 1, color: Colors.grey[800]),
                          ProfileItem(
                            icon: Icons.lock,
                            title: "Password",
                            value: "Change",
                            isAction: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Settings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEEEEEE),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.grey[900],
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          ProfileItem(
                            icon: Icons.notifications,
                            title: "Notifications",
                            value: "On",
                            isAction: true,
                          ),
                          Divider(thickness: 1, color: Colors.grey[800]),
                          ProfileItem(
                            icon: Icons.language,
                            title: "Language",
                            value: "English",
                            isAction: true,
                          ),
                          Divider(thickness: 1, color: Colors.grey[800]),
                          ProfileItem(
                            icon: Icons.dark_mode,
                            title: "Dark Mode",
                            value: "On",
                            isAction: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2879fe),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 5,
                  ),
                  onPressed: () async {
                    final updatedData = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(userData: widget.userData),
                      ),
                    );

                    if (updatedData != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(userData: Map<String, String?>.from(updatedData)),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {
                // Implement logout functionality
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.grey[900],
                    title: const Text(
                      "Logout",
                      style: TextStyle(color: Color(0xFFEEEEEE)),
                    ),
                    content: const Text(
                      "Are you sure you want to logout?",
                      style: TextStyle(color: Color(0xFFEEEEEE)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel", style: TextStyle(color: Color(0xFF2879fe))),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2879fe),
                        ),
                        onPressed: () {
                          // Implement actual logout
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text("Logout"),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2879fe),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        currentIndex: 2, // Set Profile as the selected tab
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CategoryPage()),
            );
          } else if (index == 2) {
            // Already on profile page
          }
        },
      ),
    );
  }
}

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isAction;

  const ProfileItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.isAction = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF2879fe),
            size: 22,
          ),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEEEEEE),
            ),
          ),
          const Spacer(),
          isAction
              ? Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: isAction ? const Color(0xFF2879fe) : const Color(0xFFEEEEEE),
                ),
              ),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF2879fe)),
            ],
          )
              : Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Color(0xFFEEEEEE)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}