import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_card_screen.dart';  // Ensure this is correctly imported
import 'package:flutter_credit_card/flutter_credit_card.dart';

class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key});

  @override
  CardListScreenState createState() => CardListScreenState();
}

class CardListScreenState extends State<CardListScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream for listening to changes in the cards collection
  Stream<List<Map<String, dynamic>>> _getCardsStream() {
    return _firestore
        .collection('users/$userId/cards')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => {
            'id': doc.id, // Get document ID from Firestore
            ...doc.data() // Include all the document data
          }).toList();
        });
  }

  // Delete card from Firestore
  Future<void> _deleteCard(String cardId) async {
    try {
      await _firestore.collection('users/$userId/cards').doc(cardId).delete();
      if (mounted) { // Ensure the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card deleted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) { // Ensure the widget is still mounted
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete card: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCardScreen()),  // Navigate to Add Card Screen
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getCardsStream(), // Listen to Firestore collection changes
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No saved cards.'));
          }

          // Display the list of cards
          final cardList = snapshot.data!;
          return LayoutBuilder(
            builder: (context, constraints) {
              double cardWidth = constraints.maxWidth * 0.8;
              double cardHeight = cardWidth * 0.6;

              return ListView.builder(
                padding: const EdgeInsets.only(top: 20),  // Add space between first card and AppBar
                itemCount: cardList.length,
                itemBuilder: (context, index) {
                  final card = cardList[index];
                  final cardId = card['id']; // Get the Firestore document ID

                  return Card(
                    elevation: 8, // Gives the 3D effect
                    margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 15), // Added space between cards
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: CreditCardWidget(
                            cardNumber: card['cardNumber'],
                            expiryDate: card['expiryDate'],
                            cardHolderName: card['cardHolderName'] ?? '',
                            cvvCode: card['cvvCode'] ?? '',
                            showBackView: false, // Show front side of the card by default
                            onCreditCardWidgetChange: (CreditCardBrand brand) {}, // Add required parameter
                            obscureCardCvv: false, // Show full CVV number
                            obscureCardNumber: false, // Show full card number
                            isHolderNameVisible: true, // Ensure cardholder name is visible
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCard(cardId), // Pass the Firestore document ID
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
