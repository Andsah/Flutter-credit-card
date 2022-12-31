
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'maskedTextInputFormatter.dart';
import 'package:flutter/services.dart';
import 'package:flip_card/flip_card.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp( MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.sourceSansProTextTheme()),
      home: const MyCustomForm()));
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
  FlipCardController flipController = FlipCardController();

  final String currentCardBackground = "assets/images/${(Random().nextInt(24) + 1)}.jpeg";

  final Map<String, Object> cardData = {
    "cardName" : "FULL NAME",
    "cardNumber" : "",
    "censoredCard": "#### #### #### ####",
    "cardMonth" : "MM",
    "cardYear" : "YY",
    "cardCvv" : "",
    "minCardYear" : DateTime.now().year.toString(),
    "cardMask" : "#### #### #### ####",
    "amexMask" : "#### ###### #####",
    "cardIssuer" : "visa",
  };

  bool isCardFlipped = false;

  final years = [
    DateTime.now().year,
    DateTime.now().year + 1,
    DateTime.now().year + 2,
    DateTime.now().year + 3,
    DateTime.now().year + 4,
    DateTime.now().year + 5,
    DateTime.now().year + 6,
    DateTime.now().year + 7,
    DateTime.now().year + 8,
    DateTime.now().year + 9,
    DateTime.now().year + 10,
  ];

  flipCard() {
    setState(() {
      isCardFlipped = !isCardFlipped;
      flipController.toggleCard();
    });
  }
  updateCardData(Object value, String field) {
    setState(() {
      cardData[field] = value;
    });
  }

  getCardType (String number) {
    var re = RegExp("^4");
    if (re.firstMatch(number) != null) return "visa";

    re = RegExp("^(34|37)");
    if (re.firstMatch(number) != null) return "amex";

    re = RegExp("^5[1-5]");
    if (re.firstMatch(number) != null) return "mastercard";

    re = RegExp("^6011");
    if (re.firstMatch(number) != null) return "discover";

    re = RegExp('^9792');
    if (re.firstMatch(number) != null) return "troy";

    return "visa"; // default type
  }

  getMask() {
    if (cardData["cardIssuer"] == "amex") {
      return cardData["amexMask"];
    }
    return cardData["cardMask"];
  }

  minCardMonth () {
    if (cardData["cardYear"].toString() == cardData["minCardYear"].toString()) {
      return DateTime.now().month + 1;
    }
    return 1;
  }

  getDateString() {
    if (cardData["cardYear"].toString().length > 2) {
      if (cardData["cardMonth"].toString().length < 2) {
        return "0${cardData["cardMonth"]}/${cardData["cardYear"].toString().substring(2)}";
      }
      return "${cardData["cardMonth"]}/${cardData["cardYear"].toString().substring(2)}";
    }
    if (cardData["cardMonth"].toString().length < 2) {
    return "0${cardData["cardMonth"]}/${cardData["cardYear"].toString()}";
    }
    return "${cardData["cardMonth"]}/${cardData["cardYear"].toString()}";
  }

  censorCard(String number) {
    int len = number.length;
    String censorMask;
    if (len < 6) {
      return number;
    }
     String paddedNumber = number.padRight(18, "X");

    if (cardData["cardIssuer"] == "amex") {
      censorMask = "****** **";
    }
    else {
      censorMask = "**** ****";
    }
    String censoredNumber = "${paddedNumber.substring(0, 4)} $censorMask${paddedNumber.substring(14)}";
    return censoredNumber.substring(0, len);
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold( backgroundColor: const Color(0xFFCAECFC),
      appBar: AppBar(
        toolbarHeight: 0,
        title: const Text('')
      ),
        body: Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
      FlipCard(
      fill: Fill.fillBack, // Fill the back side of the card to make in the same size as the front.
        direction: FlipDirection.HORIZONTAL, // default
        controller: flipController,
        flipOnTouch: false,
        front: Container( height: 190, width: 300, padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(14)),
              image: DecorationImage(
                  image: AssetImage(currentCardBackground),
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.1),
                      BlendMode.darken
                  ),
                  fit: BoxFit.cover),
              boxShadow: [
         BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 5), // changes position of shadow
                ),
              ],),
          child: Column( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Padding(padding: const EdgeInsets.only(bottom: 10), child: SizedBox(height: 40, width:50, child:
              Image.asset("assets/images/chip.png"))),
              Padding(padding: const EdgeInsets.only(bottom: 10), child: SizedBox(height: 40, width:50, child:
              Image.asset("assets/images/${cardData["cardIssuer"]}.png")))
          ]),
            Text(cardData["censoredCard"].toString(), style: GoogleFonts.sourceCodePro(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column( crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Card Holder", style: GoogleFonts.sourceCodePro(fontSize: 10.5, color: Colors.grey.shade100)),
              const SizedBox(height: 4),
              Text(cardData["cardName"].toString().toUpperCase(), style: GoogleFonts.sourceCodePro(color: Colors.white, fontSize: 15))]),
            Column( children: [
              Text("Expires", style: GoogleFonts.sourceCodePro(fontSize: 10.5, color: Colors.grey.shade100)),
              const SizedBox(height: 4),
              Text(getDateString(), style: GoogleFonts.sourceCodePro(color: Colors.white))])
            ]),
          ])
        ),
        back: Container( margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(14)),
            image: DecorationImage(
                image: AssetImage(currentCardBackground),
                fit: BoxFit.cover),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 5), // changes position of shadow
              ),
            ],),
          child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end,
              children: [ const SizedBox(height: 8),
                Container( height: 38, color: Colors.black),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Container(margin: const EdgeInsets.only(right: 15), child: Text("cvv", style: GoogleFonts.sourceCodePro(fontSize: 10, color: Colors.white))),
                  Container(alignment: Alignment.centerRight ,margin: const EdgeInsets.only(right: 10, left: 10, bottom: 20),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        color: Colors.white
                      ),
                    child: Text("".padRight(cardData["cardCvv"].toString().length,"*"),
                      style: GoogleFonts.sourceCodePro(fontSize: 15, height: 2.5))
                  )]),
                Padding(padding: const EdgeInsets.only(right: 15, bottom: 10), child: SizedBox(height: 40, width:50, child:
                Image.asset("assets/images/${cardData["cardIssuer"]}.png"))),

              ]
          ),
        ),
      ),
    Expanded(child:
    SingleChildScrollView( padding: const EdgeInsets.only(top: 10),
        child: Container( margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
    BoxShadow(
      color: Color(0x66777777),
      spreadRadius: 5,
      blurRadius: 7,
      offset: Offset(0, 5), // changes position of shadow
    ),
        ],),
        child:
      Padding(padding: const EdgeInsets.all(20.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
          TextFormField(
            // CREDIT CARD NUMBER
            decoration: const InputDecoration(
              icon: Icon(Icons.credit_card),
              labelText: 'Credit Card Number',
            ),
            keyboardType: TextInputType.number,
            onChanged: (String value) {
              var len = value.length;
              String cardIssuer = getCardType(value);
              updateCardData(cardIssuer, "cardIssuer");
              String mask = getMask();

              String censoredCard = censorCard(value);
              String paddingString = mask.substring(len);

              updateCardData(value + paddingString, "cardNumber");
              updateCardData(censoredCard + paddingString, "censoredCard");
            },
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
              MaskedTextInputFormatter(mask: getMask(), separator: ' ')
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please fill out your credentials.';
              }
              else if (cardData["cardIssuer"].toString() != "amex" && value.length < 19 ) {
                return 'Please enter your full credit card number.';
              }

              else if ( value.length < 17) {
                return 'Please enter your full credit card number.';
              }
              return null;
            },
          ),
          TextFormField(
            // NAME HOLDER
            decoration: const InputDecoration(
              icon: Icon(Icons.drive_file_rename_outline),
              labelText: 'Card Name',
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(24)
            ],
            onChanged: (String value) {
              updateCardData(value, "cardName");
              if (value.isEmpty) {
                updateCardData("FULL NAME", "cardName");
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please fill in your name.';
              }
              return null;
            },
          ),
        Row(crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
          SizedBox(width: 130, child:DropdownButtonFormField(items: const [ // CARD MONTH
            DropdownMenuItem(child: Text("01"), value: 01),
            DropdownMenuItem(child: Text("02"), value: 02),
            DropdownMenuItem(child: Text("03"), value: 03),
            DropdownMenuItem(child: Text("04"), value: 04),
            DropdownMenuItem(child: Text("05"), value: 05),
            DropdownMenuItem(child: Text("06"), value: 06),
            DropdownMenuItem(child: Text("07"), value: 07),
            DropdownMenuItem(child: Text("08"), value: 08),
            DropdownMenuItem(child: Text("09"), value: 09),
            DropdownMenuItem(child: Text("10"), value: 10),
            DropdownMenuItem(child: Text("11"), value: 11),
            DropdownMenuItem(child: Text("12"), value: 12)],
            decoration: const InputDecoration(
              icon: Icon(Icons.calendar_month),
              labelText: 'Expiration date',
            ),
              onChanged: (value) {  updateCardData(value.toString(), "cardMonth");},
            validator: (value) {
              if (value == null || cardData["cardMonth"] == "MM") {
                return 'Please select a month.';
              }
              else if (value < minCardMonth()) {
                return "Please choose a valid month.";
              }
              return null;
            },
            hint: const Text("Month"),
          )),
          SizedBox(width: 100, child:DropdownButtonFormField(items: [ // CARD YEAR
            DropdownMenuItem(value: years[0], child: Text("${years[0]}")),
            DropdownMenuItem(value: years[1], child: Text("${years[1]}")),
            DropdownMenuItem(value: years[2], child: Text("${years[2]}")),
            DropdownMenuItem(value: years[3], child: Text("${years[3]}")),
            DropdownMenuItem(value: years[4], child: Text("${years[4]}")),
            DropdownMenuItem(value: years[5], child: Text("${years[5]}")),
            DropdownMenuItem(value: years[6], child: Text("${years[6]}")),
            DropdownMenuItem(value: years[7], child: Text("${years[7]}")),
            DropdownMenuItem(value: years[8], child: Text("${years[8]}")),
            DropdownMenuItem(value: years[9], child: Text("${years[9]}")),
            DropdownMenuItem(value: years[10], child: Text("${years[10]}"))],
              onChanged: (value) {
            updateCardData(value.toString(), "cardYear");
            if (int.parse(cardData["cardMonth"].toString()) < minCardMonth()) {
              updateCardData("MM", "cardMonth");
              value = null;
            }
          },
            validator: (value) {
              if (value == null || cardData["cardYear"] == "YY") {
                return 'Please select a year.';
              }
              return null;
            },
            hint: const Text("Year")
          )),
          const SizedBox(width: 10),
          Focus( onFocusChange: (hasFocus) {
            if (hasFocus && !isCardFlipped) {
              flipCard();
            }
            if (!hasFocus && isCardFlipped) {
              flipCard();
            }
          },
              child: SizedBox(width: 80, child: TextFormField(// CVV
            decoration: const InputDecoration(
              icon: Icon(Icons.shield_outlined),
              labelText: 'Cvv',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4)
            ],
            onChanged: (String value) {
              updateCardData(value, "cardCvv");
            },
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 3) {
                return 'Please fill in the cvv number.';
              }
              return null;
            },
          )))]
          ),
        const SizedBox(height: 25),
        SizedBox(width: 355, child: ElevatedButton(
            onPressed: () {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Confirming Purchase')),
                );
              }
            },
            child: const Text('Submit'),
          ))]
        )
      )
    )
    )),
        ],
      ),
    ),
    );
  }
}
