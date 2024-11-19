import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_card_screen.dart';

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card deleted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
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
                MaterialPageRoute(builder: (context) => const AddCardScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getCardsStream(),
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

          final cardList = snapshot.data!;
          return LayoutBuilder(
            builder: (context, constraints) {
              double cardWidth = constraints.maxWidth * 0.8;

              return ListView.builder(
                padding: const EdgeInsets.only(top: 20),
                itemCount: cardList.length,
                itemBuilder: (context, index) {
                  final card = cardList[index];
                  final cardId = card['id'];

                  // Use default value for expiryDate if null
                  final expiryDate = card['expiryDate'] ?? 'MM/YY';

                  return Card(
                    elevation: 8,
                    margin: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        // Display asset image
                        Image.asset(
                          'assets/images/credit-card-gold.jpg', // Replace with your asset image path
                          width: cardWidth,
                          height: cardWidth * 0.6,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Expiry Date: $expiryDate',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCard(cardId),
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
