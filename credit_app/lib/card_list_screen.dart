import 'dart:async';
import 'dart:convert';
import 'package:credit_app/add_card_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CardListScreen extends StatefulWidget {
  const CardListScreen({super.key});

  @override
  CardListScreenState createState() => CardListScreenState();
}

class CardListScreenState extends State<CardListScreen> {
  final String userId = "676ab3e27835727941172573"; // Replace with actual user ID
  final String baseUrl = "http://localhost:3000"; // Replace with your API base URL

  late StreamController<List<Map<String, dynamic>>> _cardStreamController;
  late Timer _pollingTimer;
  List<Map<String, dynamic>> _userCards = [];

  @override
  void initState() {
    super.initState();
    _cardStreamController = StreamController.broadcast();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer.cancel();
    _cardStreamController.close();
    super.dispose();
  }

  void _startPolling() {
    // Fetch data every 5 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final cards = await fetchUserCards();
      _cardStreamController.add(cards); // Add data to the stream
      setState(() {
        _userCards = cards;
      });
    });
  }

  Future<List<Map<String, dynamic>>> fetchUserCards() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$userId/selectedcards'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map((card) {
          return {
            'id': card['cardId'] ?? '', // Default to empty string if null
            'expiryDate': card['expiryDate'] ?? 'N/A',
            'selectedBank': card['bankName'] ?? 'Unknown Bank',
            'selectedCard': card['cardName'] ?? 'Unnamed Card',
            'selectedCardImage': card['cardImageUrl'] ?? '', // Default to empty if no image URL
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch cards: ${response.body}');
      }
    } catch (e) {
      print("Error fetching cards: $e");
      return [];
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
            onPressed: () async {
              // Navigate to AddCardScreen and refresh data after return
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddCardScreen()),
              );
              // Trigger manual refresh after adding a card
              _pollingTimer.tick;
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _cardStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No cards saved yet.'));
          }

          final userCards = snapshot.data!;

          return ListView.builder(
            itemCount: userCards.length,
            itemBuilder: (context, index) {
              final card = userCards[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                elevation: 5,
                child: ListTile(
                  leading: card['selectedCardImage']!.isNotEmpty
                      ? Image.network(
                          card['selectedCardImage']!,
                          width: 40,
                          height: 40,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.credit_card, size: 40);
                          },
                        )
                      : const Icon(Icons.credit_card, size: 40),
                  title: Text(card['selectedCard']!),
                  subtitle: Text(
                      'Bank: ${card['selectedBank']}\nExpiry: ${card['expiryDate']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await deleteCard(card['id']); // Call delete API
                      setState(() {
                        _userCards.removeWhere((element) => element['id'] == card['id']);
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> deleteCard(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/users/$userId/cards/$id'));
      if (response.statusCode == 200) {
        print("Card deleted successfully.");
      } else {
        print("Failed to delete card: ${response.body}");
      }
    } catch (e) {
      print("Error deleting card: $e");
    }
  }
}


