import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  AddCardScreenState createState() => AddCardScreenState();
}

class AddCardScreenState extends State<AddCardScreen> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> _saveCard() async {
    if (formKey.currentState!.validate()) {
      try {
        await _firestore.collection('users/$userId/cards').add({
          'cardNumber': cardNumber,
          'expiryDate': expiryDate,
          'cardHolderName': cardHolderName,
          'cvvCode': cvvCode,
        });
        if (mounted) {
          Navigator.pop(context); // Navigate back after saving
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.toString())));
        }
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
            // Display the card UI with entered data live
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName.isNotEmpty ? cardHolderName : 'Card Holder', // Display name
              cvvCode: cvvCode,
              showBackView: isCvvFocused, // Show back view when CVV is focused
              obscureCardNumber: false,
              obscureCardCvv: false,
              onCreditCardWidgetChange: (CreditCardBrand brand) {},
            ),
            const SizedBox(height: 20),
            // Form to enter card details
            CreditCardForm(
              formKey: formKey,
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              onCreditCardModelChange: (CreditCardModel data) {
                setState(() {
                  cardNumber = data.cardNumber;
                  expiryDate = data.expiryDate;
                  cardHolderName = data.cardHolderName;
                  cvvCode = data.cvvCode;
                  isCvvFocused = data.isCvvFocused;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveCard,
              child: const Text("Save Card"),
            ),
          ],
        ),
      ),
    );
  }
}
