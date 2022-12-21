import 'package:flutter/material.dart';
import 'dart:math';
import 'maskedTextInputFormatter.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MaterialApp( home: MyCustomForm()));
}

// Define a custom Form widget.
class MyCustomForm extends StatefulWidget {
  const MyCustomForm({super.key});

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final Map<String, Object> cardData = {
    "currentCardBackground" : Random().nextInt(24) + 1, // just for fun :D
    "cardName" : "",
    "cardNumber" : "#### #### #### ####",
    "cardMonth" : "",
    "cardYear" : "",
    "cardCvv" : "",
    "minCardYear" : DateTime.now().year,
    "cardMask" : "#### #### #### ####",
    "cardIssuer" : "",
    "isCardFlipped" : false,
    "isInputFocused" : false
  };

  updateCardData(Object value, String field) {
    setState(() {
      cardData[field] = value;
    });
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit card')
      ),
        body: Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Text(cardData["cardNumber"].toString()),
          TextFormField(
            // The validator receives the text that the user has entered.
            decoration: const InputDecoration(
              icon: Icon(Icons.credit_card),
              labelText: 'Credit Card Number',
            ),
            keyboardType: TextInputType.number,
            onChanged: (String value) {
              var len = value.length;
              String paddingString = cardData["cardMask"].toString().substring(len);
              updateCardData(value + paddingString, "cardNumber");
            },
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
              MaskedTextInputFormatter(mask: cardData["cardMask"].toString(), separator: ' ')
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please fill out your credentials.';
              }
              else if ( value.length < 19) {
                return 'Please enter your full credit card number.';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Processing Data')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    ),
    );
  }
}
