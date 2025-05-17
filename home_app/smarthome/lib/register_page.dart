import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:http/http.dart' as http; // Import http package for API calls
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://10.0.2.2:3000/api/register');
      
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            "firstName": _firstNameController.text.trim(),
            "secoundName": _secondNameController.text.trim(), // use same spelling as backend expects
            "email": _emailController.text.trim(),
            "password": _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeeeeee), // Set background color to #eee
      appBar: AppBar(
        backgroundColor: const Color(0xFF00adef),
        title: const Text(
          "Sentinel Home",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color(0xFFEEEEEE),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.person_add, color: Color(0xFF3871c1), size: 100,), // Person icon
              SizedBox(width: 10), // Space between icon and text
              const Text(
                "Sign-Up",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3871c1),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _firstNameController,
                style: const TextStyle(color: Colors.black), // Set text color to black
                decoration: const InputDecoration(
                  labelText: "First Name",
                  labelStyle: TextStyle(color: Colors.black), // Label text color
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person, color: Colors.black), // Icon color
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your First Name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _secondNameController,
                style: const TextStyle(color: Colors.black), // Set text color to black
                decoration: const InputDecoration(
                  labelText: "Second Name",
                  labelStyle: TextStyle(color: Colors.black), // Label text color
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person, color: Colors.black), // Icon color
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Second Name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.black), // Set text color to black
                decoration: const InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: Colors.black), // Label text color
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Colors.black), // Icon color
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.black), // Set text color to black
                decoration: const InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Colors.black), // Label text color
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Colors.black), // Icon color
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.black), // Set text color to black
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  labelStyle: TextStyle(color: Colors.black), // Label text color
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Colors.black), // Icon color
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3871c1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text(
                  "Already have an account? Sign-In",
                  style: TextStyle(
                    color: Color(0xFF3871c1),
                    fontSize: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
