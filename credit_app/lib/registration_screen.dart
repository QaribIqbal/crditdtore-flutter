import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  String? _registrationMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              TextField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'),
              ),
              const SizedBox(height: 20),
              if (_registrationMessage != null) ...[
                Text(
                  _registrationMessage!,
                  style: TextStyle(
                    color: _registrationMessage!.contains('successfully')
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    setState(() {
      _registrationMessage = "Registering...";
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _fullNameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'phoneNumber': _phoneNumberController.text,
          'city': _cityController.text,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        setState(() {
          _registrationMessage = "Registration successful!";
        });
      } else {
        setState(() {
          _registrationMessage = "Registration failed: ${responseBody['error']}";
        });
      }
    } catch (e) {
      setState(() {
        _registrationMessage = "Unexpected error: $e";
      });
    }
  }
}
