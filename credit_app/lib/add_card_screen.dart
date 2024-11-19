import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  AddCardScreenState createState() => AddCardScreenState();
}

class AddCardScreenState extends State<AddCardScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String expiryDate = '';
  String selectedBank = '';
  String selectedCard = '';
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

  Future<void> _loadBanks() async {
    try {
      setState(() {
        isLoading = true;
      });

      QuerySnapshot snapshot = await _firestore.collection('banks').get();

      setState(() {
        banks = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'],
            'imageUrl': doc['imageUrl'],
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching banks: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadCreditCards(String bankName) async {
    try {
      final bankSnapshot = await FirebaseFirestore.instance
          .collection('banks')
          .where('name', isEqualTo: bankName)
          .limit(1)
          .get();

      if (bankSnapshot.docs.isEmpty) {
        print('Bank not found!');
        return;
      }

      final bankData = bankSnapshot.docs.first.data();
      final List<String> cardIds = List<String>.from(bankData['creditCards'] ?? []);

      if (cardIds.isEmpty) {
        print('No credit cards found for this bank.');
        return;
      }

      List<Map<String, dynamic>> creditCards = [];
      for (String cardId in cardIds) {
        final creditCardSnapshot = await FirebaseFirestore.instance
            .collection('credit_cards')
            .doc(cardId)
            .get();

        if (creditCardSnapshot.exists) {
          creditCards.add(creditCardSnapshot.data()!);
        }
      }

      setState(() {
        this.creditCards = creditCards;
      });
    } catch (e) {
      print('Error fetching credit cards: $e');
    }
  }

  // Function to validate expiry date
  bool _isValidExpiryDate(String date) {
    // Check if date is in MM/YY format
    final regex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    if (!regex.hasMatch(date)) {
      setState(() {
        errorMessage = 'Invalid expiry date format. Please use MM/YY.';
      });
      return false;
    }

    // Check if the expiry date is in the future
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
      // Validate the expiry date before saving the card
      if (!_isValidExpiryDate(expiryDate)) {
        return;
      }

      try {
        await _firestore.collection('users/$userId/cards').add({
          'expiryDate': expiryDate,
          'selectedBank': selectedBank,
          'selectedCard': selectedCard,
        });
        if (mounted) {
          Navigator.pop(context);
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
        title: const Text('Add Card'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () async {
                  final Map<String, dynamic>? bank = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Select a Bank'),
                        content: SingleChildScrollView(
                          child: Column(
                            children: banks.map((bank) {
                              return ListTile(
                                title: Text(bank['name']),
                                onTap: () {
                                  Navigator.pop(context, bank);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  );

                  if (bank != null) {
                    setState(() {
                      selectedBank = bank['name'];
                      _loadCreditCards(bank['name']);
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance, size: 30),
                      const SizedBox(width: 10),
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
            if (creditCards.isNotEmpty)
              Column(
                children: creditCards.map((card) {
                  return ListTile(
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
                        selectedCard = card['name'];
                        selectedCardImage = card['imageUrl'];
                      });

                      // Show dialog to add expiry date
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
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),
            if (selectedCard.isNotEmpty)
              Column(
                children: [
                  Text(
                    'Selected Card: $selectedCard',
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
    );
  }
}
