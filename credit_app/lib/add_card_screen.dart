import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding and decoding
import 'card_list_screen.dart'; // Ensure this is the correct import for CardListScreen

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  AddCardScreenState createState() => AddCardScreenState();
}

class AddCardScreenState extends State<AddCardScreen> {
  final String userId = "676ab3e27835727941172573"; // Set this based on your auth logic
  String expiryDate = '';
  String selectedBank = '';
  String selectedCard = '';
  String selectedCardName= ''; // Name of the selected card
  String selectedCardImage = ''; // Image path for selected card
  String errorMessage = ''; // For showing error messages

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> banks = [];
  List<Map<String, dynamic>> creditCards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBanks();
  }

  // Fetch the banks from the backend API
  Future<void> _loadBanks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/banks'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          banks = data.map((bank) => {
            'id': bank['_id'],
            'name': bank['name'],
            'imageUrl': bank['iconUrl'], // Assuming 'iconUrl' holds the image URL
          }).toList();
          isLoading = false;
        });
      } else {
        print('Failed to load banks');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching banks: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Load credit cards based on selected bank
  Future<void> _loadCreditCards(String bankId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/$bankId'));

      if (response.statusCode == 200) {
        List<dynamic> cardsData = json.decode(response.body);
        setState(() {
          creditCards = cardsData.map((card) => {
            'cardId': card['cardId'],
            'name': card['name'],
            'imageUrl': card['imageUrl'],
          }).toList();
        });
      } else {
        print('Failed to load credit cards');
      }
    } catch (e) {
      print('Error fetching credit cards: $e');
    }
  }

  bool _isValidExpiryDate(String date) {
    final regex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    if (!regex.hasMatch(date)) {
      setState(() {
        errorMessage = 'Invalid expiry date format. Please use MM/YY.';
      });
      return false;
    }

    final now = DateTime.now();
    final parts = date.split('/');
    final month = int.parse(parts[0]);
    final year = int.parse(parts[1]);
    final expiryDate = DateTime(2000 + year, month);

    if (expiryDate.isBefore(now)) {
      setState(() {
        errorMessage = 'Expiry date cannot be in the past.';
      });
      return false;
    }

    setState(() {
      errorMessage = '';
    });
    return true;
  }

  Future<void> _saveCard() async {
    if (expiryDate.isNotEmpty && selectedBank.isNotEmpty && selectedCard.isNotEmpty) {
      if (!_isValidExpiryDate(expiryDate)) {
        return;
      }

      try {
        await http.post(
          Uri.parse('http://localhost:3000/users/$userId/cards'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'expiryDate': expiryDate,
            'cardId': selectedCard,
              }),
        );

        if (mounted) {
         /* Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CardListScreen()),
          );*/
           ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card Saved Successfully'))
           );
        }
      } catch (e) {
        print("Error saving card: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Card', style:TextStyle(color: Colors.blue , fontSize: 35 ,fontWeight: FontWeight.w400)),
       // backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600), // Ensure a max width for larger screens
              child: Column(
                children: <Widget>[
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButton<String>(
                          value: selectedBank.isEmpty ? null : selectedBank,
                          hint: const Text('Select a Bank'),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedBank = newValue!;
                              _loadCreditCards(selectedBank);
                            });
                          },
                          items: banks.map<DropdownMenuItem<String>>((Map<String, dynamic> bank) {
                            return DropdownMenuItem<String>(
                              value: bank['id'],
                              child: Row(
                                children: [
                                  Image.network(
                                    bank['imageUrl'],
                                    width: 40,
                                    height: 40,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.account_balance, size: 40);
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  Text(bank['name']),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 20),
                  if (creditCards.isNotEmpty)
                    Column(
                      children: creditCards.map((card) {
                        return Card(
                          elevation: 4, // Adds shadow to the card
                          margin: const EdgeInsets.symmetric(vertical: 8), // Adds vertical spacing
                          child: ListTile(
                            leading: Image.network(
                              card['imageUrl'],
                              width: 40,
                              height: 40,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.credit_card, size: 40);
                              },
                            ),
                            title: Text(card['name']),
                            onTap: () async {
                              setState(() {
                                selectedCard = card['cardId'];
                                selectedCardName = card['name'];
                                selectedCardImage = card['imageUrl'];
                             //   print(selectedCard); // Set selected card image
                              });

                              final String? date = await showDialog<String>(
                                context: context,
                                builder: (context) {
                                  String expiryInput = '';
                                  return AlertDialog(
                                    title: const Text('Enter Expiry Date'),
                                    content: TextField(
                                      keyboardType: TextInputType.datetime,
                                      decoration: const InputDecoration(
                                        labelText: 'MM/YY',
                                      ),
                                      onChanged: (value) {
                                        expiryInput = value;
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, null),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, expiryInput),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (date != null && date.isNotEmpty) {
                                setState(() {
                                  expiryDate = date;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 20),
                  if (selectedCard.isNotEmpty)
                    Column(
                      children: [
                        Text(
                          'Selected Card: $selectedCardName',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Image.network(
                          selectedCardImage,
                          width: 200,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 10),
                        if (expiryDate.isNotEmpty)
                          Text(
                            'Expiry Date: $expiryDate',
                            style: const TextStyle(fontSize: 16),
                          ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: selectedBank.isEmpty || selectedCard.isEmpty || expiryDate.isEmpty ? null : _saveCard,
                    child: const Text("Save Card"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
