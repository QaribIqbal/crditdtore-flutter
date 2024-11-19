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

  Future<void> _saveCard() async {
    if (expiryDate.isNotEmpty && selectedBank.isNotEmpty && selectedCard.isNotEmpty) {
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
                    leading: Image.asset(
                    //  'assets/images/credit-card-gold.jpg', // Replace with dynamic asset loading if needed
                      card['imageUrl'],
                      width: 40,
                      height: 40,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.credit_card, size: 40);
                      },
                    ),
                    title: Text(card['name']),
                    onTap: () {
                      setState(() {
                        selectedCard = card['name'];
                        selectedCardImage = card['imageUrl']; //'assets/images/credit-card-gold.png'; // Update dynamically
                      });
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
                  Image.asset(
                    //  'assets/images/credit-card-gold.jpg',
                   selectedCardImage,
                    width: 200,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ],
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
