import 'package:credit_app/add_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key});

  @override
  CardListScreenState createState() => CardListScreenState();
}

class CardListScreenState extends State<CardListScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Stream<QuerySnapshot> userCardsStream;

  @override
  void initState() {
    super.initState();
    // Set up the real-time listener to monitor changes to the cards collection.
    userCardsStream = _firestore.collection('users/$userId/cards').snapshots();
  }

  Future<void> _deleteCard(String cardId) async {
    try {
      await _firestore.collection('users/$userId/cards').doc(cardId).delete();
    } catch (e) {
      print("Error deleting card: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cards'),
         automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddCardScreen())); // Navigate to Add Card screen
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userCardsStream, // Listen to changes in the cards collection
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No cards saved yet.'));
          }

          final userCards = snapshot.data!.docs.map((doc) {
            return {
              'id': doc.id,
              'expiryDate': doc['expiryDate'],
              'selectedBank': doc['selectedBank'],
              'selectedCard': doc['selectedCard'],
              'selectedCardImage': doc['selectedCardImage'],
            };
          }).toList();

          return ListView.builder(
            itemCount: userCards.length,
            itemBuilder: (context, index) {
              final card = userCards[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                elevation: 5,
                child: ListTile(
                  leading: Image.network(
                    card['selectedCardImage'], // Card image URL
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.credit_card, size: 40);
                    },
                  ),
                  title: Text(card['selectedCard']), // Card name
                  subtitle: Text('Bank: ${card['selectedBank']}\nExpiry: ${card['expiryDate']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteCard(card['id']), // Delete card
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
