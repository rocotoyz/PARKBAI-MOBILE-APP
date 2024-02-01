import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ParkingHistoryInfo extends StatefulWidget {
  final String ParkingHistoryKey;
  final String ownerHistoryKey;
  ParkingHistoryInfo(
      {required this.ParkingHistoryKey, required this.ownerHistoryKey});

  @override
  State<ParkingHistoryInfo> createState() => _ParkingHistoryInfoState();
}

//HEXCOLOR FOR COLORPALLETE
int hexColor(String color) {
  String newColor = '0xff' + color;
  newColor = newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}

// Function to display SnackBar
void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: Duration(seconds: 5),
      backgroundColor: Color(hexColor('#003459')),
    ),
  );
}

class _ParkingHistoryInfoState extends State<ParkingHistoryInfo> {
  DatabaseReference? parkHistoryRef;
  DatabaseReference? parkingRatingRef;
  DatabaseReference? addCommentRef;
  Stream? parkingHistoryInfoStream;
  Stream? parkingRatingStream;

  double rating = 3.0; // Initial rating
  void pushParkingRatingStream() async {
    final User? userRatingref = await FirebaseAuth.instance.currentUser;
    if (userRatingref != null) {
      parkingRatingRef = FirebaseDatabase.instance
          .ref()
          .child('PARK_OWNER')
          .child(widget.ownerHistoryKey)
          .child('PARKING_RATING');

      Map<dynamic, dynamic> ratings = {
        'rating': rating,
        'user_uid': userRatingref.uid
      };
      parkingRatingRef?.push().set(ratings);
    }

    addComment(widget.ParkingHistoryKey);
  }


  void addComment(String ownerHistoryKey) {
    TextEditingController commentController = TextEditingController();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 350),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, a1, a2, widget) {
        double screenWidth = MediaQuery.of(context).size.width;
        double dialogWidth = screenWidth < 400 ? screenWidth * 0.9 : 400;

        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0.0, -1.0),
            end: Offset(0.0, 0.0),
          ).animate(a1),
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            backgroundColor: Color(0xFF003459),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Container(
              width: dialogWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "Do you want to say something?",
                        style: GoogleFonts.raleway(
                          fontSize: 18,
                          color: Color(0xFFE4F4FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: commentController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'comment here.',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Later",
                            style: GoogleFonts.raleway(
                              fontSize: 16.5,
                              color: Color(0xFFE2C946),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            RatingPopUp(
                                commentController.text, ownerHistoryKey);
                            print(ownerHistoryKey);
                             print('ni gana ra ?');
                          },
                          child: Text(
                            "Proceed",
                            style: GoogleFonts.raleway(
                              fontSize: 16.5,
                              color: Color(0xFFE2C946),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void RatingPopUp(String commentController, String ownerHistoryKey) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 350),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, a1, a2, widget) {
        double screenWidth = MediaQuery.of(context).size.width;
        double dialogWidth = screenWidth < 400 ? screenWidth * 0.9 : 400;

        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0.0, -1.0),
            end: Offset(0.0, 0.0),
          ).animate(a1),
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            backgroundColor: Color(hexColor('#003459')),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Container(
              width: dialogWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        "Your opinion matters to us.",
                        style: GoogleFonts.raleway(
                          fontSize: 17,
                          color: Color(0xFFE4F4FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "How would you rate this parking service?",
                      style: GoogleFonts.raleway(
                        fontSize: 15,
                        color: Color(0xFFE4F4FF),
                      ),
                    ),
                  ),
                  Center(
                    child: RatingBar.builder(
                      initialRating: 3,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Color(0xFFE2C946),
                        size: 24,
                      ),
                      onRatingUpdate: (newRating) {
                        setState(() {
                          rating = newRating;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.raleway(
                              fontSize: 16.5,
                              color: Color(0xFFE2C946),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (commentController.isEmpty) {
                              pushParkingRatingStream();
                              Navigator.of(context).pop();
                            } else {
                              final User? userCommentref =
                                  await FirebaseAuth.instance.currentUser;
                              if (userCommentref != null) {
                                addCommentRef = FirebaseDatabase.instance
                                    .ref()
                                    .child('PARK_OWNER')
                                    .child(ownerHistoryKey)
                                    .child('PARKING_RATING');

                                Map<dynamic, dynamic> comment = {
                                  'comment': commentController.toString(),
                                  'rating': rating,
                                  'user_uid': userCommentref.uid
                                };
                                addCommentRef?.push().set(comment);
                              }
                              showSnackBar(
                                  context, "Thank you for the ratings.");

                              Navigator.of(context).pop();
                            }
                          },
                          child: Text(
                            "Submit",
                            style: GoogleFonts.raleway(
                              fontSize: 16.5,
                              color: Color(0xFFE2C946),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initializeParkingHistoryInfoStream(widget.ParkingHistoryKey);
  }

  void initializeParkingHistoryInfoStream(String ParkingHistoryKey) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      parkHistoryRef = FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(user.uid)
          .child('PARKING_HISTORY')
          .child(ParkingHistoryKey);
      parkingHistoryInfoStream = parkHistoryRef!.onValue;
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: parkingHistoryInfoStream,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          DataSnapshot dataValues = snapshot.data!.snapshot;
          if (dataValues.value != null && dataValues.value is Map) {
            final Map<dynamic, dynamic> parkingHistoryData =
                dataValues.value as Map<dynamic, dynamic>;

            final String? date = parkingHistoryData['date']?.toString();
            final String? timeIn = parkingHistoryData['time_in']?.toString();
            final String? timeOut = parkingHistoryData['time_out']?.toString();
            final double? totalHour =
                parkingHistoryData['hours_park']?.toDouble();
            final double? addFee = parkingHistoryData['add_Fee']?.toDouble();
            final double? overnight_fee =
                parkingHistoryData['overnight_fee']?.toDouble();
            final int? totalPayment =
                parkingHistoryData['total_payment']?.toInt();
            final String? rfid = parkingHistoryData['rfid']?.toString();
            final String? refnumber =
                parkingHistoryData['ref_number']?.toString();
            final String? location =
                parkingHistoryData['park_address']?.toString();
            final String? parkingArea =
                parkingHistoryData['company_name']?.toString();
            return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: Text('PARKING HISTORY',
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
                                          'Time in: ',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${timeIn}',
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
                                          'Time out: ',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${timeOut}',
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
                                          'Hours park: ',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${totalHour}',
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
                                          'Additional fee: ',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${addFee}',
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
                                          'Overnight fee: ',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${overnight_fee}',
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
                                          'Total fee: ',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '₱${totalPayment}.00',
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
                                        Expanded(
                                          child: Text(
                                            'Park location: ',
                                            style: GoogleFonts.raleway(
                                              fontSize:
                                                  17, // Adjusted font size
                                              color: Color(0xFFE2C946),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              top: 13, right: 57.0),
                                          width: 200,
                                          child: Text(
                                            '${location}',
                                            style: GoogleFonts.raleway(
                                              fontSize:
                                                  14, // Adjusted font size
                                              color: Color(0xFFE4F4FF),
                                              fontWeight: FontWeight.bold,
                                            ),
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
                                          'Parking lot name: ',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${parkingArea}',
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
                                          'RFID: ',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${rfid}',
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
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            GestureDetector(
                              child: Text(
                                'Rate us!',
                                style: GoogleFonts.raleway(
                                  fontSize: 20,
                                  color: Color(0xFFE2C946),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                print("mo click");
                                addComment(widget.ownerHistoryKey);
                              },
                            ),
                          ],
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
