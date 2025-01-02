import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DiscountOffersScreen extends StatefulWidget {
  const DiscountOffersScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DiscountOffersScreenState createState() => _DiscountOffersScreenState();
}

class _DiscountOffersScreenState extends State<DiscountOffersScreen> {
  final baseUrl = "http://localhost:3000";
  List<dynamic> offers = [];
  List<dynamic> filteredOffers = [];
  String selectedType = "";
  String selectedCity = "";
  String selectedCards = "";
  List<String> category = [];
//  List<String> types = ['Health', 'Food', 'Electronics', 'Clothing']; // Example types
  List<String> types = []; // Example types
  List<String> cities = [
    "All",
    "Lahore",
    "Faisalabad",
    "Islamabad",
    "Karachi",
    "Multan",
    "Sargodah",
    "Peshawar"
  ];
  List<Map<String, dynamic>> userCards = []; //user cards
  List<Map<String, dynamic>> banks = [];
  bool isLoading = true;
  List<Map<String, dynamic>> creditCards = [];
  List<Map<String, dynamic>> cardList = [];
  String selectedBank = '';
  @override
  void initState() {
    super.initState();
    fetchOffers();
    fetchCategories();
    _loadBanks();
  }

  Future<void> _loadBanks() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/banks'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          banks = data
              .map((bank) => {
                    'id': bank['_id'],
                    'name': bank['name'],
                    'imageUrl': bank[
                        'iconUrl'], // Assuming 'iconUrl' holds the image URL
                  })
              .toList();
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
    print('Loading credit cards for bank ID: $bankId');
    setState(() {
      isLoading = true; // Show loading indicator while fetching cards
      creditCards = []; // Clear previous cards before fetching new ones
    });
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/$bankId'));

      if (response.statusCode == 200) {
        List<dynamic> cardsData = json.decode(response.body);
        setState(() {
          creditCards = cardsData
              .map((card) => {
                    'cardId': card['cardId'],
                    'name': card['name'],
                    'imageUrl': card['imageUrl'],
                  })
              .toList();
          isLoading = false; // Hide loading indicator after successful fetch
        });
        //    print('Parsed Credit Cards: $creditCards');
      } else {
        // print('Failed to load credit cards');
        setState(() {
          isLoading = false; // Hide loading indicator even on failure
        });
      }
    } catch (e) {
      print('Error fetching credit cards: $e');
      setState(() {
        isLoading = false; // Hide loading indicator even on error
      });
    }
  }

  Future<Iterable<Map<String, dynamic>>> fetchUserCards() async {
    try {
      const userId = '677539c26668532c16e10d7e';
      final response =
          await http.get(Uri.parse('$baseUrl/users/$userId/selectedcards'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((card) {
          return {
            'id': card['cardId'] ?? '', // Default to empty string if null
            'expiryDate': card['expiryDate'] ?? 'N/A',
            'selectedBank': card['bankName'] ?? 'Unknown Bank',
            'selectedCard': card['cardName'] ?? 'Unnamed Card',
          };
        }).toList();
      } else {
        throw Exception('Failed to fetch cards: ${response.body}');
      }
    } catch (e) {
      print("Error: $e");
      print("Failed to load user cards");
      return [];
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:3000/categories/category'));
      final data = json.decode(response.body);
      final List<String> categoryNames = (data['categories'] as List)
          .map((category) => category['name'] as String)
          .toList();
      categoryNames.insert(0, 'All');
      setState(() {
        //types=category.map((category) => category['name']).toList();010t();
        types = categoryNames;
      });
    } catch (e) {
      print("Error: $e");
      print("Failed to load categories");
    }
  }

  Future<void> fetchOffers() async {
    try {
      if (selectedType == 'All') {
        selectedType = '';
      }
      if (selectedCity == 'All') {
        selectedCity = '';
      }
      final response = await http.get(Uri.parse(
          '$baseUrl/discounts/offers?category=$selectedType&location=$selectedCity&card=$selectedCards'));
      if (response.statusCode == 200) {
        setState(() {
          offers = json.decode(response.body);
          filteredOffers = List.from(offers);
          print(selectedCards);
        });
      } else {
        // Handle error
        print("Failed to load offers");
        print(response.body);
      }
    } catch (e) {
      // Handle error
      print("Error: $e");
    }
  }

  void openFilterPopup() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Dropdown
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: selectedType.isEmpty ? null : selectedType,
                  items: types.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedType = value ?? "";
                    });
                  },
                ),
                const SizedBox(height: 12),

                // City Dropdown
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: selectedCity.isEmpty ? null : selectedCity,
                  items: cities.map((String city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      selectedCity = value ?? "";
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Bank Dropdown
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Bank',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  value: selectedBank.isEmpty ? null : selectedBank,
                  items: banks.map<DropdownMenuItem<String>>(
                      (Map<String, dynamic> bank) {
                    return DropdownMenuItem<String>(
                      value: bank['id'],
                      child: Row(
                        children: [
                          Image.network(
                            bank['imageUrl'],
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.account_balance,
                                  size: 40);
                            },
                          ),
                          const SizedBox(width: 10),
                          Text(bank['name']),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedBank = newValue!;
                      _loadCreditCards(selectedBank);
                    });
                    Navigator.pop(context); // Close the modal
                    _loadCreditCards(selectedBank);
                  },
                ),

                // Loading indicator while fetching credit cards
                if (isLoading) ...[
                  const SizedBox(height: 8),
                  const Center(child: CircularProgressIndicator()),
                ],

                // Show Credit Card Dropdown once data is loaded
                if (!isLoading && creditCards.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Card',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    value: selectedCards.isEmpty ? null : selectedCards,
                    items: creditCards.map((card) {
                      return DropdownMenuItem<String>(
                        value: card['cardId'],
                        child: Row(
                          children: [
                            Image.network(
                              card['imageUrl'],
                              width: 40,
                              height: 40,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.credit_card, size: 40);
                              },
                            ),
                            const SizedBox(width: 10),
                            Text(card['name']),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        // Instead of adding, directly set the selected card
                        selectedCards = value ?? '';
                      });
                    },
                  ),
                ],

               // const SizedBox(height: 12),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 0, top: 13),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                      
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedType = '';
                                selectedCity = '';
                                selectedCards = '';
                                selectedBank = '';
                              });
                              Navigator.pop(context); // Close the modal
                              openFilterPopup();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 31, 31),
                            ),
                            child: const Text('Reset',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                          SizedBox(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: ElevatedButton(
                            onPressed: () {
                              fetchOffers();
                              Navigator.pop(context); // Close the modal
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text('Apply',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Discount Offers',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
          actions: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: ElevatedButton.icon(
                label: const Text("Filter"),
                icon: const Icon(Icons.filter_alt),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                ),
                onPressed: openFilterPopup,
              ),
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Column(
          children: [
            // Offers Grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 700,
                  mainAxisExtent: 300,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 7,
                ),
                itemCount: filteredOffers.length,
                itemBuilder: (context, index) {
                  final offer = filteredOffers[index];
                  return Card(
                    elevation: 15,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'images/gym.jpg',
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Text(
                            offer['location']['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text('offer: ${offer['name']}'),
                          Text('Discount: ${offer['discountPercentage']}%'),
                          Text('Location: ${offer['location']['city']}'),
                          Text('Address:${offer['location']['address']}')
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
