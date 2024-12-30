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
    String selectedCity = "";
  List<String> selectedCards = [];
  List<String> category=[];
//  List<String> types = ['Health', 'Food', 'Electronics', 'Clothing']; // Example types
  List<String> types = []; // Example types
 List<String> cities=["All","Lahore","Faisalabad","Islamabad","Karachi","Multan","Sargodah","Peshawar"];

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
                DropdownButtonFormField<String>(
                  
                  isExpanded: true,
                  decoration: InputDecoration(labelText: 'Type' ,border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),),
                  value: selectedType.isEmpty ? null : selectedType,
                  items: types.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedType = value ?? "";
                    });
                 //   fetchOffers();
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(labelText: 'City',border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),),
                  value: selectedCity.isEmpty ? null : selectedCity,
                  items: cities.map((city) {
                    return DropdownMenuItem(value: city, child: Text(city));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCity = value ?? "";
                    });
                 //   fetchOffers();
                  },
                ),
                const SizedBox(height: 8),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 38,top:38),
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4, // 80%
                      child: ElevatedButton(
                        onPressed: () {
                          fetchOffers();
                         // applyFilters();
                          Navigator.pop(context);
                        },
                        style:ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue,),
                        child: const Text('Apply',style:TextStyle(color: Colors.white)),
                      ),
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
        backgroundColor:Colors.lightBlue,
        actions:[  Padding(
            padding: const EdgeInsets.all(3.0),
            child:ElevatedButton.icon(
               label: const Text("Filter Offers"),
                icon: const Icon(Icons.filter_alt),
                onPressed: openFilterPopup,
              ),
          ),]
       
      ),
      body: Padding(
        padding: const EdgeInsets.only(top:5),
        child: Column(
          children: [
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
      ),
    );
  }
}
