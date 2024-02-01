import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';


class PaymentHistoryInfo extends StatefulWidget {
  final String PaymentHistoryKey;
  PaymentHistoryInfo({required this.PaymentHistoryKey});

  @override
  State<PaymentHistoryInfo> createState() => _PaymentHistoryInfoState();
}

//HEXCOLOR FOR COLORPALLETE
int hexColor(String color) {
  String newColor = '0xff' + color;
  newColor = newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}

class _PaymentHistoryInfoState extends State<PaymentHistoryInfo> {
  DatabaseReference? paymentHistoryRef;
  Stream? paymentHistorynfoStream;

  @override
  void initState() {
    super.initState();
    initializePaymentHistoryInfoStream(widget.PaymentHistoryKey);
  }

  void initializePaymentHistoryInfoStream(String PaymentHistoryKey) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      paymentHistoryRef = FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(user.uid)
          .child('PAYMENT_HISTORY')
          .child(PaymentHistoryKey);
      paymentHistorynfoStream = paymentHistoryRef!.onValue;
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: paymentHistorynfoStream,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          DataSnapshot dataValues = snapshot.data!.snapshot;
          if (dataValues.value != null && dataValues.value is Map) {
            final Map<dynamic, dynamic> parkingHistoryData =
                dataValues.value as Map<dynamic, dynamic>;

            final String? date = parkingHistoryData['date']?.toString();
             final String? amount = parkingHistoryData['amount']?.toString();
            final String? transaction =
                parkingHistoryData['transaction_details']?.toString();
            final String? mop = parkingHistoryData['MOP']?.toString();
            final String? refnumber =
                parkingHistoryData['ref_number']?.toString();
            return Scaffold(
                appBar: AppBar(
                  leading: BackButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  centerTitle: true,
                  title: Text('PAYMENT HISTORY',
                      style: GoogleFonts.raleway(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                  backgroundColor: Color(hexColor('#003459')),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.7,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color:
                                Color(hexColor('#003459')), // Background color
                            borderRadius: BorderRadius.circular(
                                10), // Optional: Add rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(0, 3),
                                blurRadius: 1,
                                spreadRadius: 0, // Shadow expands
                              ),
                            ],
                          ),
                          child: Container(
                              margin: EdgeInsets.only(top: 90.0),
                              height: MediaQuery.of(context).size.height *
                                  0.7, // Adjusted height
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE2C946),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${transaction}',
                                          style: GoogleFonts.raleway(
                                            fontSize: 18,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Date: ',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${date}',
                                          style: GoogleFonts.raleway(
                                            fontSize: 16,
                                            color: Color(0xFFE4F4FF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                      Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Amount: ',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '₱${amount}.00',
                                          style: GoogleFonts.raleway(
                                            fontSize: 16,
                                            color: Color(0xFFE4F4FF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Mode of Payment: ',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${mop}',
                                          style: GoogleFonts.raleway(
                                            fontSize: 16,
                                            color: Color(0xFFE4F4FF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          'Reference number: ',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${refnumber}',
                                          style: GoogleFonts.raleway(
                                            fontSize: 16,
                                            color: Color(0xFFE4F4FF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ],
                  ),
                ));
          } else {
            // Handle the case where the 'users' node or expected data is missing
            return Text('Parking history data not found.');
          }
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      });
}
