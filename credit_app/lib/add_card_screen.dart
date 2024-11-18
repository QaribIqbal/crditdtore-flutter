import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  AddCardScreenState createState() => AddCardScreenState();
}

class AddCardScreenState extends State<AddCardScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  String selectedBank = '';  // To store the selected bank

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // List to hold the banks fetched from Firestore
  List<Map<String, dynamic>> banks = [];
  bool isLoading = true;  // Track loading state

  @override
  void initState() {
    super.initState();
    _loadBanks();  // Load the bank data when the screen is initialized
  }

  // Fetch bank data from Firestore
  Future<void> _loadBanks() async {
    try {
      // Show a loading indicator
      setState(() {
        isLoading = true;
      });

      // Get the list of banks from Firestore
      QuerySnapshot snapshot = await _firestore.collection('banks').get();

      // Check if data exists
      if (snapshot.docs.isEmpty) {
        debugPrint("No banks found in Firestore.");
      } else {
        debugPrint("Banks fetched from Firestore: ${snapshot.docs.length}");
      }

      setState(() {
        banks = snapshot.docs.map((doc) {
          return {
            'name': doc['name'] as String,        // Cast to String
            'imageUrl': doc['imageUrl'] as String, // Cast to String
          };
        }).toList();
        isLoading = false;  // Hide loading indicator
      });
    } catch (e) {
      debugPrint("Error fetching banks: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to show the bank selection dialog
  void _selectBank() async {
    final Map<String, String>? selected = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a Bank'),
          content: SingleChildScrollView(
            child: Column(
              children: banks.map((bank) {
                return ListTile(
                  leading: Image.network(
                    bank['imageUrl']!, // Load image from URL
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.account_balance, size: 40);
                    },
                  ),
                  title: Text(bank['name']!),
                  onTap: () {
                    Navigator.pop(context, bank); // Return the selected bank
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selected != null && selected.isNotEmpty) {
      setState(() {
        selectedBank = selected['name']!;  // Store the selected bank name
      });
    }
  }

  // Function to save the card details to Firestore
  Future<void> _saveCard() async {
    if (formKey.currentState!.validate()) {
      try {
        await _firestore.collection('users/$userId/cards').add({
          'cardNumber': cardNumber,
          'expiryDate': expiryDate,
          'cardHolderName': cardHolderName,
          'cvvCode': cvvCode,
          'selectedBank': selectedBank,  // Save selected bank
        });
        if (mounted) {
          Navigator.pop(context); // Navigate back after saving
        }
      } catch (e) {
        debugPrint("Error saving card: $e");
      }
    }
  }

  // Method to add banks to Firestore programmatically
  Future<void> _addBanksToFirestore() async {
    // Create a list of banks with their names and image URLs
   List<Map<String, String>> bankData = [
  // Systemically Important Banks
  {'name': 'Habib Bank Limited (HBL)', 'imageUrl': ''},
  {'name': 'National Bank of Pakistan (NBP)', 'imageUrl': ''},
  {'name': 'United Bank Limited (UBL)', 'imageUrl': ''},
];


    try {
      // Loop through the bank data and add each bank to Firestore
      for (var bank in bankData) {
        await _firestore.collection('banks').add({
          'name': bank['name'],
          'imageUrl': bank['imageUrl'],
        });
      }
      debugPrint("Banks added successfully!");
    } catch (e) {
      debugPrint("Error adding banks to Firestore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Card'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Bank selection UI
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: _selectBank,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      if (selectedBank.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Icon(Icons.account_balance, size: 30),
                        ),
                      Text(
                        selectedBank.isEmpty ? 'Select Bank' : selectedBank,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Show loading indicator if banks are loading
            if (isLoading) 
              const Center(child: CircularProgressIndicator()),

            // Show the banks if available
            if (!isLoading && banks.isNotEmpty)
              ElevatedButton(
                onPressed: _selectBank, // Show the bank selection dialog
                child: const Text("Select Bank"),
              ),
            
            if (banks.isEmpty && !isLoading)
              const Text("No banks available", style: TextStyle(fontSize: 16)),

            const SizedBox(height: 20),

            // Display the card UI with entered data live
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName.isNotEmpty ? cardHolderName : 'Card Holder',
              cvvCode: cvvCode,
              showBackView: isCvvFocused,
              obscureCardNumber: false,
              obscureCardCvv: false,
              onCreditCardWidgetChange: (CreditCardBrand brand) {},
            ),
            const SizedBox(height: 20),
            
            // Form to enter card details
            CreditCardForm(
              formKey: formKey,
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              onCreditCardModelChange: (CreditCardModel data) {
                setState(() {
                  cardNumber = data.cardNumber;
                  expiryDate = data.expiryDate;
                  cardHolderName = data.cardHolderName;
                  cvvCode = data.cvvCode;
                  isCvvFocused = data.isCvvFocused;
                });
              },
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: selectedBank.isEmpty ? null : _saveCard, // Disable if no bank is selected
              child: const Text("Save Card"),
            ),
            const SizedBox(height: 20),
            
            // Button to add banks to Firestore
            ElevatedButton(
              onPressed: _addBanksToFirestore, // Call the method to add banks
              child: const Text("Add Banks to Firestore"),
            ),
          ],
        ),
      ),
    );
  }
}
