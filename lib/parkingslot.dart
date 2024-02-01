import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class ParkingSlot extends StatefulWidget {
  final String parkingKey;
  final String parkingLayout;

  ParkingSlot({required this.parkingKey, required this.parkingLayout});

  @override
  State<ParkingSlot> createState() => _ParkingLotState();
}

class ParkingLot {
  final String areaKey;
  final String lotkey;
  final String nodeData;

  ParkingLot({
    required this.lotkey,
    required this.areaKey,
    required this.nodeData,
  });
}

int hexColor(String color) {
  String newColor = '0xff' + color;
  newColor = newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}

class _ParkingLotState extends State<ParkingSlot> {
  DatabaseReference? userRef;
  DatabaseReference? ownerReferrence;
  Stream? userDataStream;
  Stream? ParkingSlotDataStream;

  // ImageProvider<Object> _image = AssetImage('assets/PARKING_LOT.png');

  @override
  void initState() {
    super.initState();
    initializeParkingSlot();
  }

  void initializeParkingSlot() {
    ownerReferrence = FirebaseDatabase.instance.ref().child('PARK_OWNER');

    ParkingSlotDataStream = ownerReferrence!.onValue;
  }

  // void initializeParkingSlot() async {
  //   ownerReferrence = FirebaseDatabase.instance
  //       .ref()
  //       .child('PARK_OWNER')
  //       .child(widget.parkingKey)
  //       .child('PARKING_LOT')
  //       .child('Profile_Picture');

  //   DatabaseEvent event = await ownerReferrence!.once();
  //   if (event.snapshot.value is Map<dynamic, dynamic>) {
  //     Map<dynamic, dynamic>? data =
  //         event.snapshot.value as Map<dynamic, dynamic>?;
  //     if (data != null && data['Profile_Picture'] != null) {
  //          String parking = data['Profile_Picture'].toString();
  //     }
  //   }
  // }

  // Future<void> loadImage() async {
  //   final Completer<ImageInfo> completer = Completer<ImageInfo>();

  //   final ImageStream stream =
  //       AssetImage('assets/PARKING_LOT.png').resolve(ImageConfiguration.empty);

  //   stream.addListener(
  //     ImageStreamListener(
  //       (ImageInfo image, bool synchronousCall) {
  //         completer.complete(image);
  //       },
  //       onError: (dynamic exception, StackTrace? stackTrace) {
  //         completer.completeError(exception);
  //       },
  //     ),
  //   );

  //   final ImageInfo imageInfo = await completer.future;
  //   //_image = imageInfo.image;
  // }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'PARKING SLOTS',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(hexColor('#003459')),
        actions: [
          // Add an IconButton to the AppBar
          IconButton(
            icon: Icon(Icons.photo),
            onPressed: () {
              // Show a dialog with a zoomable image from the images folder
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context)
                            .size
                            .width, // Adjust as needed
                      ),
                      // width: MediaQuery.of(context).size.width,
                      height: 350.0,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(0, 3),
                            blurRadius: 5,
                            spreadRadius: 0, // Shadow expands
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage('${widget.parkingLayout}'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: Color(hexColor('#003459')),
      body: Container(
          child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(hexColor('#003459')), // Background color
              borderRadius:
                  BorderRadius.circular(10), // Optional: Add rounded corners
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
              child: StreamBuilder(
                stream: ParkingSlotDataStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data.snapshot.value != null) {
                    Map<dynamic, dynamic> values = snapshot.data.snapshot.value;
                    List<ParkingLot> slot = [];

                    values.forEach((key, value) {
                      if (value['PARKING_AREA'] != null &&
                          key == widget.parkingKey) {
                        final parkingAreaData = value['PARKING_AREA'];

                        parkingAreaData.forEach((areaKey, areaValue) {
                          final nodeData = areaValue['parking_space'] ?? '';
                          slot.add(ParkingLot(
                            lotkey: key, // Use the renamed property
                            areaKey: areaKey,
                            nodeData: nodeData,
                          ));
                        });
                      }
                    });

                    if (slot.isNotEmpty) {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of columns
                          crossAxisSpacing: 5.0, // Spacing between columns
                          mainAxisSpacing: 5.0, // Spacing between rows
                          childAspectRatio:
                              1.1, // Ratio of width to height for each tile
                        ),
                        itemCount: slot.length,
                        itemBuilder: (context, index) {
                          Color tileColor;

                          // Set color based on the value of nodeData
                          if (slot[index].nodeData == 'VACANT') {
                            tileColor = Colors.green;
                          } else if (slot[index].nodeData == 'OCCUPIED') {
                            tileColor = Colors.red;
                          } else {
                            // Default color if neither VACANT nor OCCUPIED
                            tileColor = Colors.yellow;
                          }
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            child: Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: tileColor,
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
                                  slot[index].areaKey,
                                  style: GoogleFonts.raleway(
                                    fontSize: 50,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  slot[index].nodeData,
                                  style: GoogleFonts.raleway(
                                    fontSize: 15,
                                    color: const Color(0xFF003459),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: Text(
                          "No Parking Slot available!",
                          style: GoogleFonts.raleway(
                            fontSize: 15,
                            color: Color(0xFFE4F4FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                  } else {
                    return Center(
                      child: Text(
                        "No Parking Slot available!",
                        style: GoogleFonts.raleway(
                          fontSize: 15,
                          color: Color(0xFFE4F4FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      )),
    );
  }
}
