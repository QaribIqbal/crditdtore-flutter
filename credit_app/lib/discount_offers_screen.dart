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
  final baseUrl="http://localhost:3000";
  List<dynamic> offers = [];
  List<dynamic> filteredOffers = [];
  String selectedType = "";
  List<String> selectedCards = [];
  List<String> category=[];
//  List<String> types = ['Health', 'Food', 'Electronics', 'Clothing']; // Example types
  List<String> types = []; // Example types


  @override
  void initState() {
    super.initState();
    fetchOffers();
    fetchCategories();
  }
Future<void> fetchCategories() async{
try{
 final response = await http.get(Uri.parse('http://localhost:3000/categories/category'));
 final data=json.decode(response.body);
     final List<String> categoryNames =(data['categories'] as List).map((category) => category['name'] as String).toList();
     categoryNames.insert(0,'All');
  setState(() {
    //types=category.map((category) => category['name']).toList();010t();
  types=categoryNames;
  });
}
catch(e)
{
  print("Error: $e");
  print("Failed to load categories");
}
}
  Future<void> fetchOffers() async {
    try {
      if(selectedType=='All')
      {
        selectedType='';
      }
      final response = await http.get(Uri.parse('$baseUrl/discounts/offers?category=$selectedType'));
      if (response.statusCode == 200) {
        setState(() {
          offers = json.decode(response.body);
          filteredOffers = List.from(offers);
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

  void applyFilters() {
    setState(() {
      filteredOffers = offers
          .where((offer) => (selectedType.isEmpty || offer['type'] == selectedType) &&
              (selectedCards.isEmpty || selectedCards.contains(offer['card'])))
          .toList();

      filteredOffers.sort((a, b) {
        if (selectedCards.isNotEmpty && a['restaurant'] == b['restaurant']) {
          return b['discount'].compareTo(a['discount']);
        }
        return b['discount'].compareTo(a['discount']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discount Offers',
        style: TextStyle(color: Colors.white)),
        backgroundColor:Colors.lightBlue
      ),
      body: Column(
        children: [
          // Search and filter bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
                child: Row(
                  children: [
                    Expanded(
                      flex:2,
                      child: DropdownButtonFormField<String>(   
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Type'),
                        value: selectedType.isEmpty ? null : selectedType,
                        items: types
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedType = value ?? "";
                          });
                          //applyFilters();//My API
                          fetchOffers();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Card Filter (comma separated)',
                        ),
                        onSubmitted: (value) {
                          setState(() {
                            selectedCards = value.split(',').map((e) => e.trim()).toList();
                          });
                        //  applyFilters(); MY API
                        fetchOffers();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Offers Grid
          Expanded(
            child: GridView.builder(
              gridDelegate:const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent:700,
                mainAxisExtent: 300,
                crossAxisSpacing: 5,
                mainAxisSpacing: 7,
              ),
              itemCount: filteredOffers.length,
              itemBuilder: (context, index) {
                final offer = filteredOffers[index];
                return Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer['location']['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
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
    );
  }
}
