import 'package:credit_app/add_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore import
import 'card_list_screen.dart'; // Replace with your project's name
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  String? _registrationMessage;

  Future<void> _register() async {
    setState(() {
      _registrationMessage = "Registering...";
    });

    try {
      // Register the user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // After user registration, save the city to Firestore
      final user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email,
          'city': _cityController.text, // Save the city
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          // Navigate to AddCardScreen after successful registration
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AddCardScreen()),
          );
        }
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
      setState(() {
        _registrationMessage = "Registration failed: ${e.message}";
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
      setState(() {
        _registrationMessage = "Unexpected error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 0, bottom: 20),
              child: const Text(
                "Register your account to access",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
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
                  color: _registrationMessage == "Registering..."
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
