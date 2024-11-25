import 'package:credit_app/card_list_screen.dart';
import 'package:flutter/material.dart';
import 'registration_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
                child: const Text('Login'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                  );
                },
                child: const Text('Register'),
              ),
              const SizedBox(height: 20),
              if (_signInMessage != null) ...[
                Text(
                  _signInMessage!,
                  style: TextStyle(
                    color: _signInMessage == "Signing in..."
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


  }
