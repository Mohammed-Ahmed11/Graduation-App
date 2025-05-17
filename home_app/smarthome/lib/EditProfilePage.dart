import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final Map<String, String?> userData;

  const EditProfilePage({super.key, required this.userData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  String username = "User"; // Default username
  String email = "email@gmail.com"; // Default username

  File? _image;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userData['username']);
    emailController = TextEditingController(text: widget.userData['email']);
    phoneController = TextEditingController(text: widget.userData['phone']);
    _loadUsername();
  }

  Future<void> _loadUsername() async {
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
              username = payloadMap['username'] ?? 'User';
              email = payloadMap['email'] ?? 'email@gmail.com';
              if (nameController.text.isEmpty) {
                nameController.text = username;
              }
              if (emailController.text.isEmpty) {
                emailController.text = email;
              }
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Here you would add your API call to save profile details
      // For demonstration, we're just simulating a delay
      await Future.delayed(const Duration(seconds: 1));

      Navigator.pop(context, {
        'fullName': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'imagePath': _image?.path,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1017), // Matching app background color
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2879fe), // Matching app blue color
        elevation: 5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "Hello, $username",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEEEEEE),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.person, color: Color(0xFFEEEEEE)),
              ],
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : const AssetImage('assets/images/profile.png') as ImageProvider,
                    backgroundColor: Colors.grey[800],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2879fe),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Tap to change profile picture',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Color(0xFFEEEEEE)),
              decoration: InputDecoration(
                labelText: "Full Name",
                labelStyle: const TextStyle(color: Color(0xFFEEEEEE)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2879fe)),
                ),
                prefixIcon: const Icon(Icons.person, color: Color(0xFFEEEEEE)),
                filled: true,
                fillColor: Colors.grey[900],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Color(0xFFEEEEEE)),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: const TextStyle(color: Color(0xFFEEEEEE)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2879fe)),
                ),
                prefixIcon: const Icon(Icons.email, color: Color(0xFFEEEEEE)),
                filled: true,
                fillColor: Colors.grey[900],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Color(0xFFEEEEEE)),
              decoration: InputDecoration(
                labelText: "Phone",
                labelStyle: const TextStyle(color: Color(0xFFEEEEEE)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade600),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2879fe)),
                ),
                prefixIcon: const Icon(Icons.phone, color: Color(0xFFEEEEEE)),
                filled: true,
                fillColor: Colors.grey[900],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2879fe),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Save Profile",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
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
          if (index != 2) {
            Navigator.pop(context);
            // Here you would navigate to the appropriate page based on index
          }
        },
      ),
    );
  }
}