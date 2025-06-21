import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'category_page.dart';
import 'register_page.dart';
import 'forget_password.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var bool_isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        bool_isLoading = true;
      });

      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      try {
        final response = await http.post(
          Uri.parse('http://localhost:3001/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200 && !data.containsKey('error')) {
          // Store the JWT token
          final String token = data["success"];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);

          // Decode the JWT token to get user info
          // JWT structure: header.payload.signature
          final parts = token.split('.');
          if (parts.length > 1) {
            // Decode payload
            final normalized = base64Url.normalize(parts[1]);
            final payload = utf8.decode(base64Url.decode(normalized));
            final payloadMap = json.decode(payload);

            final String username = payloadMap['username'] ?? 'User';
            final String email = payloadMap['email'] ?? 'User';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login successful! Welcome $username')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login successful!')),
            );
          }

          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => CategoryPage()),
          );
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? 'Login failed')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }

      setState(() {
        bool_isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1017), // Set background color to #0d1017
      appBar: AppBar(
        backgroundColor: const Color(0xFF2879fe),
        title: const Text(
          "HUB HOME HYPER",
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
              Icon(
                Icons.person,
                color: Color(0xFF2879fe),
                size: 100,
              ), // Person icon
              SizedBox(width: 10), // Space between icon and text
              const Text(
                "Sign-In",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2879fe),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(
                  color: Color(0xFFEEEEEE),
                ), // Set text color
                decoration: const InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: Color(0xFFEEEEEE)), // Label text color
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Color(0xFFEEEEEE)), // Icon color
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
                style: const TextStyle(
                  color: Color(0xFFEEEEEE),
                ), // Set text color
                decoration: const InputDecoration(
                  labelText: "Password",
                  labelStyle: TextStyle(color: Color(0xFFEEEEEE)), // Label text color
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Color(0xFFEEEEEE)), // Icon color
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgetPasswordPage()),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color(0xFF2879fe),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: bool_isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2879fe),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: bool_isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Login",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                    color: Color(0xFF2879fe),
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