import 'package:credit_app/add_card_screen.dart';
import 'package:credit_app/card_list_screen.dart';
import 'package:credit_app/discount_offers_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:credit_app/login_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 //await dotenv.load(); // Load the .env file
  // Fetch users when the app starts
  await fetchUsers();
  await _loadConfig();
WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// Function to fetch users from the backend
Future<void> _loadConfig() async {
  try {
    final response = await http.get(Uri.parse('http://localhost:3000/config'));
    if (response.statusCode == 200) {
      final config = jsonDecode(response.body);
      final String baseUrl = config['baseUrl'];
      // Use the baseUrl in your API calls
    }
  } catch (e) {
    print('Error loading config: $e');
  }
}
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
      home: const LoginScreen(),
    // const DiscountOffersScreen(),
    //const CardListScreen(),
   // const MainScreen(),
    );
    
  }
}
 class MainScreen extends StatefulWidget{
  const MainScreen({super.key});
 @override 
 MainScreenState createState()=> MainScreenState();  
 }
  class MainScreenState extends State<MainScreen>{
  int selectedindex=0;
  //list of screen navigation
  static final List<Widget> screens =[
    const DiscountOffersScreen(),
    const CardListScreen(),
    const AddCardScreen(),
  ];
//navigation bar working 
void onItemTapped(int index){
setState(() {
  selectedindex=index;
});
}

@override
  Widget build(BuildContext context){
    return Scaffold(
      body: screens[selectedindex],
     bottomNavigationBar: BottomNavigationBar(items: const <BottomNavigationBarItem>[
       BottomNavigationBarItem(
         icon: Icon(Icons.local_offer),
         label: 'Offers',
       ),
       BottomNavigationBarItem(
         icon: Icon(Icons.credit_card),
         label: 'My Cards',
       ),
       BottomNavigationBarItem(
         icon: Icon(Icons.add),
         label: 'Add Card',
       ),
     ],
     currentIndex: selectedindex,
     selectedItemColor: Colors.blue,
     onTap: onItemTapped,
    )
    );
  }
  }
