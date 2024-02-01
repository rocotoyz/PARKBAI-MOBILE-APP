import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parkbai/paymenthistory.dart';
import 'package:parkbai/main.dart';
import 'package:parkbai/parkinghistoryinfo.dart';

class ParkingHistory extends StatefulWidget {
  const ParkingHistory({super.key});

  @override
  State<ParkingHistory> createState() => _ParkingHistoryState();
}

class goingTopPageRoute extends PageRouteBuilder {
  final Widget nextPage;

  goingTopPageRoute({required this.nextPage})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => nextPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0); // Slide from bottom
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

class goingLeftPageRoute extends PageRouteBuilder {
  final Widget nextPage;

  goingLeftPageRoute({required this.nextPage})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => nextPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

class parkingHistory {
  final key;
  final date;
  final rfid;
  final timeIn;
  final timeOut;
  final hourPark;
  final totalPayment;
  final refNumber;
  final ownerID;

  parkingHistory(this.key, this.date, this.rfid, this.timeIn, this.timeOut,
      this.hourPark, this.totalPayment, this.refNumber, this.ownerID);
}

class _ParkingHistoryState extends State<ParkingHistory> {
  DatabaseReference? userRef;
  DatabaseReference? ParkingHistoryDeleted;
  Stream? parkingHistoryDataStream;

//HEXCOLOR FOR COLORPALLETE
  int hexColor(String color) {
    String newColor = '0xff' + color;
    newColor = newColor.replaceAll('#', '');
    int finalColor = int.parse(newColor);
    return finalColor;
  }

  @override
  void initState() {
    super.initState();
    initializeParkingHistoryDataStream();
  }

  void initializeParkingHistoryDataStream() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userRef = FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(user.uid)
          .child('PARKING_HISTORY');

      parkingHistoryDataStream = userRef!.onValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              goingLeftPageRoute(nextPage: MainPage()),
            );
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
          padding: const EdgeInsets.only(top: 15),
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 33),
                      child: Text(
                        'PARKING HISTORY',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE2C946),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 50),
                      child: GestureDetector(
                        child: Text(
                          'PAYMENT HISTORY',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE4F4FF),
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            goingLeftPageRoute(
                              nextPage: PaymentHistory(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder(
                stream: parkingHistoryDataStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data.snapshot.value != null) {
                    Map<dynamic, dynamic> values = snapshot.data.snapshot.value;
                    List<parkingHistory> items = [];
                    values.forEach((key, value) {
                      final date = value['date'] ?? '';
                      final rfid = value['rfid'] ?? '';
                      final timeIn = value['time_in'] ?? '';
                      final timeOut = value['time_out'] ?? '';
                      final hourPark = value['hours_park'] ?? '';
                      final totalPayment = value['total_payment'] ?? '';
                      final refNumber = value['ref_number'] ?? '';
                      final ownerID = value['ownerID'] ?? '';
                      items.add(parkingHistory(key, date, rfid, timeIn, timeOut,
                          hourPark, totalPayment, refNumber, ownerID));
                    });

                    items.sort((a, b) => a.key.compareTo(b.key));

                    return Center(
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Color(hexColor('#003459')), // Background color
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
                                      items[index].key,
                                      style: GoogleFonts.raleway(
                                        fontSize: 17,
                                        color: const Color(0xFFE2C946),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      items[index].refNumber.toString(),
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
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                title: Center(
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "Are you sure you want to delete?",
                                                        style:
                                                            GoogleFonts.raleway(
                                                          fontSize: 16,
                                                          color:
                                                              Color(0xFFE4F4FF),
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                                fontSize: 15,
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
                                                              final User? user =
                                                                  await FirebaseAuth
                                                                      .instance
                                                                      .currentUser;
                                                              if (user !=
                                                                  null) {
                                                                ParkingHistoryDeleted = await FirebaseDatabase
                                                                    .instance
                                                                    .ref()
                                                                    .child(
                                                                        'DRIVER')
                                                                    .child(user
                                                                        .uid)
                                                                    .child(
                                                                        'PARKING_HISTORY')
                                                                    .child(items[
                                                                            index]
                                                                        .key)
                                                                    .remove() as DatabaseReference?;
                                                                print(
                                                                    "deleted");
                                                                print(
                                                                    items[index]
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
                                                                fontSize: 15,
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
                                          nextPage: ParkingHistoryInfo(
                                            ParkingHistoryKey: items[index].key,
                                             ownerHistoryKey: items[index].ownerID, 
                                       
                                             
                                          ),
                                        ),
                                    
                                      );
                                 
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) =>
                                      //         ParkingHistoryInfo(
                                      //       ParkingHistoryKey: items[index].key,
                                      //     ),
                                      //   ),
                                      // );
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
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
