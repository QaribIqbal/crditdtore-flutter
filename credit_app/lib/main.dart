import 'package:credit_app/add_card_screen.dart';
import 'package:credit_app/card_list_screen.dart';
import 'package:credit_app/discount_offers_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:credit_app/login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);

  // Fetch users when the app starts
  await fetchUsers();

  runApp(const MyApp());
}

// Function to fetch users from the backend
Future<void> fetchUsers() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:3000/users'));

    if (response.statusCode == 200) {
      // Parse the JSON response
      List<dynamic> users = json.decode(response.body);
      print('Users fetched: $users');
    } else {
      print('Failed to load users');
    }
  } catch (e) {
    print('Error fetching users: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Credit App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home:// const LoginScreen(),
      DiscountOffersScreen(),
    //const CardListScreen(),
    );
  }
}
