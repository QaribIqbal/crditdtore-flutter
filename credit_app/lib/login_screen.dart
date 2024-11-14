import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'card_list_screen.dart';  // Update with your project name

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _signInMessage;

  Future<void> _signIn() async {
    setState(() {
      _signInMessage = "Signing in...";
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CardListScreen()), // Add const
        );
      }
    } on FirebaseException catch (e) {
      // Specific handling for FirebaseException
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
      setState(() {
        _signInMessage = "Sign in failed: ${e.message}";
      });
    } catch (e) {
      // Generic catch for other exceptions
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
      setState(() {
        _signInMessage = "Unexpected error: $e";
      });
    }
  }

  Future<void> _register() async {
    setState(() {
      _signInMessage = "Registering...";
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CardListScreen()), // Add const
        );
      }
    } on FirebaseException catch (e) {
      // Specific handling for FirebaseException
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
      setState(() {
        _signInMessage = "Registration failed: ${e.message}";
      });
    } catch (e) {
      // Generic catch for other exceptions
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
      setState(() {
        _signInMessage = "Unexpected error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Please sign in to access your credit cards',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signIn,
                child: const Text('Login'), // Add const
              ),
              const SizedBox(height: 10), // Add space between buttons
              ElevatedButton(
                onPressed: _register,
                child: const Text('Register'), // Add const
              ),
              const SizedBox(height: 20),
              if (_signInMessage != null) ...[
                Text(
                  _signInMessage!,
                  style: TextStyle(
                    color: _signInMessage == "Signing in..." || _signInMessage == "Registering..."
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
}
