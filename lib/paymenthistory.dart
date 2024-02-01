import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: unused_import
import 'package:parkbai/parkinghistoryinfo.dart';
import 'package:parkbai/parkinghistory.dart';
import 'package:parkbai/paymenthistoryinfo.dart';
// ignore: unused_import
import 'package:parkbai/main.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({super.key});

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

//HEXCOLOR FOR COLORPALLETE
int hexColor(String color) {
  String newColor = '0xff' + color;
  newColor = newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}

class paymentHistory {
  final key;
  final date;
  final mop;
  final transaction;
  final refNumber;

  paymentHistory(
      this.key, this.date, this.transaction, this.mop, this.refNumber);
}

class _PaymentHistoryState extends State<PaymentHistory> {
  DatabaseReference? PaymentHistoryDeleted;
  DatabaseReference? userRef;
  Stream? paymentHistoryDataStream;

  @override
  void initState() {
    super.initState();
    initializePaymentHistoryDataStream();
  }

  void initializePaymentHistoryDataStream() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userRef = FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(user.uid)
          .child('PAYMENT_HISTORY');
      paymentHistoryDataStream = userRef!.onValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text('TRANSACTION HISTORY',
            style: GoogleFonts.raleway(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Color(hexColor('#003459')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 15),
          child: Column(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 33),
                        child: GestureDetector(
                          child: Text(
                            'PARKING HISTORY',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE4F4FF),
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: Text(
                          'PAYMENT HISTORY',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE2C946),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  )),
              Container(
                child: StreamBuilder(
                    stream: paymentHistoryDataStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data.snapshot.value != null) {
                        Map<dynamic, dynamic> values =
                            snapshot.data.snapshot.value;
                        List<paymentHistory> items = [];
                        values.forEach((key, value) {
                          final date = value['date'] ?? '';
                          final transaction =
                              value['transaction_details'] ?? '';
                          final mop = value['MOP'] ?? '';
                          final refNumber = value['ref_number'] ?? '';
                          items.add(paymentHistory(
                              key, date, transaction, mop, refNumber));
                        });
                        return Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Color(
                                  hexColor('#003459')), // Background color
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
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(top: 20),
                              height: 300,
                              width: MediaQuery.of(context).size.width,
                              // width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE2C946),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListView.builder(
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(hexColor('#003459')),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black,
                                            offset: Offset(0, 1),
                                            blurRadius: 0,
                                            spreadRadius: 0, // Shadow expands
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        title: Text(
                                          items[index].transaction,
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: const Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          items[index].date,
                                          style: GoogleFonts.raleway(
                                            fontSize: 15,
                                            color: Color(0xFFE4F4FF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete_rounded),
                                          color: Color(0xFFE2C946),
                                          iconSize: 23,
                                          onPressed: () async {
                                            showGeneralDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              barrierLabel: '',
                                              transitionDuration:
                                                  Duration(milliseconds: 350),
                                              pageBuilder: (context, animation1,
                                                  animation2) {
                                                return Container();
                                              },
                                              transitionBuilder:
                                                  (context, a1, a2, widget) {
                                                return SlideTransition(
                                                  position: Tween<Offset>(
                                                    begin: Offset(0.0, -1.0),
                                                    end: Offset(0.0, 0.0),
                                                  ).animate(a1),
                                                  child: AlertDialog(
                                                    backgroundColor:
                                                        Color(0xFF003459),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    title: Center(
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            "Are you sure you want to delete?",
                                                            style: GoogleFonts
                                                                .raleway(
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFFE4F4FF),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                  "Cancel",
                                                                  style: GoogleFonts
                                                                      .raleway(
                                                                    fontSize:
                                                                        15,
                                                                    color: Color(
                                                                        0xFFE2C946),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed:
                                                                    () async {
                                                                  final User?
                                                                      user =
                                                                      await FirebaseAuth
                                                                          .instance
                                                                          .currentUser;
                                                                  if (user !=
                                                                      null) {
                                                                    PaymentHistoryDeleted = await FirebaseDatabase
                                                                        .instance
                                                                        .ref()
                                                                        .child(
                                                                            'DRIVER')
                                                                        .child(user
                                                                            .uid)
                                                                        .child(
                                                                            'PAYMENT_HISTORY')
                                                                        .child(items[index]
                                                                            .key)
                                                                        .remove() as DatabaseReference?;
                                                                    print(
                                                                        "deleted");
                                                                    print(items[
                                                                            index]
                                                                        .key);
                                                                  }
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                                child: Text(
                                                                  "Yes",
                                                                  style: GoogleFonts
                                                                      .raleway(
                                                                    fontSize:
                                                                        15,
                                                                    color: Color(
                                                                        0xFFE2C946),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            goingTopPageRoute(
                                              nextPage: PaymentHistoryInfo(
                                                PaymentHistoryKey:
                                                    items[index].key,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
