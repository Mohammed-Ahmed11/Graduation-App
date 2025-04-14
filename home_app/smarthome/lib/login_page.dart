import 'package:flutter/material.dart';
import 'register_page.dart'; // Import Register Page for navigation
import 'forget_password.dart'; // Import Forget Password Page

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

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Perform login logic here (e.g., Firebase authentication)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful!')),
      );
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
              Icon(
                Icons.person,
                color: Color(0xFF3871c1),
                size: 100,
              ), // Person icon
              SizedBox(width: 10), // Space between icon and text
              const Text(
                "Sign-In",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3871c1),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(
                    color: Colors.black), // Set text color to black
                decoration: const InputDecoration(
                  labelText: "Email",
                  labelStyle:
                      TextStyle(color: Colors.black), // Label text color
                  border: OutlineInputBorder(),
                  prefixIcon:
                      Icon(Icons.email, color: Colors.black), // Icon color
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
                    color: Colors.black), // Set text color to black
                decoration: const InputDecoration(
                  labelText: "Password",
                  labelStyle:
                      TextStyle(color: Colors.black), // Label text color
                  border: OutlineInputBorder(),
                  prefixIcon:
                      Icon(Icons.lock, color: Colors.black), // Icon color
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
                      MaterialPageRoute(
                          builder: (context) => ForgetPasswordPage()),
                    );
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color(0xFF3871c1),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3871c1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
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
                    MaterialPageRoute(
                        builder: (context) => const RegisterPage()),
                  );
                },
                child: const Text(
                  "Don't have an account? Sign Up",
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
