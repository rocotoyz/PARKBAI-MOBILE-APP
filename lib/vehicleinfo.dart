import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class VehicleInfo extends StatefulWidget {
  final String vehicleKey;
  VehicleInfo({required this.vehicleKey});

  @override
  State<VehicleInfo> createState() => _VehicleInfoState();
}

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
      duration: Duration(seconds: 3),
      backgroundColor: Color(hexColor('#003459')),
        shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(8.0),
        topRight: Radius.circular(8.0),
      ),
    ),
    ),
  );
}

class _VehicleInfoState extends State<VehicleInfo> {
  DatabaseReference? vehicleRef;
  Stream? vehicleDataStream;

  DatabaseReference? removeVehicleRef;
  Stream? removeVehicleStream;

  @override
  void initState() {
    super.initState(); // Pass the vehicleKey to the method
    initializeUserDataStream();
  }

  void initializeUserDataStream() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      vehicleRef = FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(user.uid)
          .child('VEHICLE')
          .child(widget.vehicleKey);

      vehicleDataStream = vehicleRef!.onValue;
    }
  }

  String reUploadVehicleImage = "";
  String reUploadVehicleDocument = "";

  void ReUploadVehicleImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    String VehicleimageName = DateTime.now().millisecondsSinceEpoch.toString();
    String Vehicleimage = '${VehicleimageName}.png';

    Reference ref = FirebaseStorage.instance
        .ref()
        .child("DRIVER")
        .child("VEHICLE")
        .child(Vehicleimage);

    await ref.putFile(File(image!.path));

    await ref.getDownloadURL().then((value) {
      //print(value);
      setState(() {
        reUploadVehicleImage = value;
      });
    });
  }

  void ReUploadVehicleDocument() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    String vehicleDocumentname =
        DateTime.now().millisecondsSinceEpoch.toString();
     String vehicleDocumentImage = '${vehicleDocumentname}.png';

    Reference ref = FirebaseStorage.instance
        .ref()
        .child("DRIVER")
        .child("VEHICLE")
        .child("DOCUMENTS")
        .child(vehicleDocumentImage);

    await ref.putFile(File(image!.path));

    await ref.getDownloadURL().then((value) {
      //print(value);
      setState(() {
        reUploadVehicleDocument = value;
      });
    });
  }

  void reUploadVehicleImagesLink() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userUID = user!.uid;
    if (reUploadVehicleImage.isNotEmpty && reUploadVehicleDocument.isNotEmpty) {
      await FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(userUID)
          .child('VEHICLE')
          .child(widget.vehicleKey)
          .update({
        'vehicleImage': reUploadVehicleImage,
        'vehicleDocument': reUploadVehicleDocument
      });
    } else if (reUploadVehicleImage.isNotEmpty) {
      await FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(userUID)
          .child('VEHICLE')
          .child(widget.vehicleKey)
          .update({'vehicleImage': reUploadVehicleImage});
    } else if (reUploadVehicleDocument.isNotEmpty) {
      await FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(userUID)
          .child('VEHICLE')
          .child(widget.vehicleKey)
          .update({'vehicleDocument': reUploadVehicleDocument});
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: vehicleDataStream,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          DataSnapshot dataValues = snapshot.data!.snapshot;
          if (dataValues.value != null && dataValues.value is Map) {
            final Map<dynamic, dynamic> vehicleData =
                dataValues.value as Map<dynamic, dynamic>;

            final String? vehicleDocument =
                vehicleData['vehicleDocument']?.toString();
            final String? vehicleImage =
                vehicleData['vehicleImage']?.toString();
            final String? platenumber = vehicleData['platenumber']?.toString();
            final String? color = vehicleData['color']?.toString();
            final String? brand = vehicleData['brand']?.toString();
            final String? model = vehicleData['model']?.toString();
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: Text('VEHICLE INFORMATION',
                    style: GoogleFonts.raleway(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                backgroundColor: Color(hexColor('#003459')),
              ),
              body: SingleChildScrollView(
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                      height: 800,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFE2C946),
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
                              child: GestureDetector(
                                onTap: () {
                                  ReUploadVehicleImage();
                                },
                                child: reUploadVehicleImage == ""
                                    ? Container(
                                        width: 350.0,
                                        height: 200.0,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black,
                                              offset: Offset(0, 3),
                                              blurRadius: 5,
                                              spreadRadius: 0, // Shadow expands
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                            image:
                                                NetworkImage('${vehicleImage}'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width: 350.0,
                                        height: 200.0,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black,
                                              offset: Offset(0, 3),
                                              blurRadius: 5,
                                              spreadRadius: 0, // Shadow expands
                                            ),
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                reUploadVehicleImage),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(13.0),
                            child: Row(
                              children: [
                                Text(
                                  'Brand: ',
                                  style: GoogleFonts.raleway(
                                    fontSize: 17,
                                    color: Color(0xFFE2C946),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${brand}',
                                  style: GoogleFonts.raleway(
                                    fontSize: 17,
                                    color: Color(0xFFE4F4FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(13.0),
                            child: Row(
                              children: [
                                Text(
                                  'Plate number: ',
                                  style: GoogleFonts.raleway(
                                    fontSize: 17,
                                    color: Color(0xFFE2C946),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${platenumber}',
                                  style: GoogleFonts.raleway(
                                    fontSize: 17,
                                    color: Color(0xFFE4F4FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(13.0),
                            child: Row(
                              children: [
                                Text(
                                  'Color: ',
                                  style: GoogleFonts.raleway(
                                    fontSize: 17,
                                    color: Color(0xFFE2C946),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${color}',
                                  style: GoogleFonts.raleway(
                                    fontSize: 17,
                                    color: Color(0xFFE4F4FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(13.0),
                            child: Row(
                              children: [
                                Text(
                                  'Model: ',
                                  style: GoogleFonts.raleway(
                                    fontSize: 17,
                                    color: Color(0xFFE2C946),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${model}',
                                  style: GoogleFonts.raleway(
                                    fontSize: 17,
                                    color: Color(0xFFE4F4FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(13.0),
                            child: Row(
                              children: [
                                Text(
                                  'Certificate of Registration: ',
                                  style: GoogleFonts.raleway(
                                    fontSize: 16,
                                    color: Color(0xFFE2C946),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 15.0),
                                child: GestureDetector(
                                  onTap: () {
                                    ReUploadVehicleDocument();
                                  },
                                  child: reUploadVehicleDocument == ""
                                      ? Container(
                                          width: 300.0,
                                          height: 170.0,
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black,
                                                offset: Offset(0, 3),
                                                blurRadius: 5,
                                                spreadRadius:
                                                    0, // Shadow expands
                                              ),
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  '${vehicleDocument}'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : Container(
                                          width: 300.0,
                                          height: 170.0,
                                          decoration: BoxDecoration(
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black,
                                                offset: Offset(0, 3),
                                                blurRadius: 5,
                                                spreadRadius:
                                                    0, // Shadow expands
                                              ),
                                            ],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  reUploadVehicleDocument),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(150, 34),
                                  backgroundColor: Color(hexColor('#003459')),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  shadowColor: Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.update_outlined),
                                    SizedBox(width: 8),
                                    Text(
                                      "UPDATE",
                                      style: GoogleFonts.raleway(
                                        fontSize: 15,
                                        color: Color(0xFFE4F4FF),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  setState(() {
                                    print(reUploadVehicleImage);
                                    print('ilahang mga link');
                                    print(reUploadVehicleDocument);
                                    print(widget.vehicleKey);
                                    reUploadVehicleImagesLink();
                               showSnackBar(context, "Vehicle information updated successfully.");
                                    Navigator.of(context).pop();
                                  });
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Center(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  fixedSize: Size(150, 34),
                                  backgroundColor: Color(hexColor('#003459')),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  shadowColor: Colors.white,
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.remove_circle_outline_outlined),
                                    SizedBox(width: 8),
                                    Text(
                                      "REMOVE",
                                      style: GoogleFonts.raleway(
                                        fontSize: 15,
                                        color: Color(0xFFE4F4FF),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                onPressed: () {
                                  setState(() {
                                    showGeneralDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierLabel: '',
                                      transitionDuration:
                                          Duration(milliseconds: 350),
                                      pageBuilder:
                                          (context, animation1, animation2) {
                                        return Container();
                                      },
                                      transitionBuilder:
                                          (context, a1, a2, widget) {
                                        // ignore: unused_local_variable
                                        double screenWidth =
                                            MediaQuery.of(context).size.width;
                                        // ignore: unused_local_variable
                                        double screenHeight =
                                            MediaQuery.of(context).size.height;

                                        return SlideTransition(
                                          position: Tween<Offset>(
                                            begin: Offset(0.0, -1.0),
                                            end: Offset(0.0, 0.0),
                                          ).animate(a1),
                                          child: AlertDialog(
                                            backgroundColor: Color(0xFF003459),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            title: Center(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    "Are you sure you want to remove?",
                                                    style: GoogleFonts.raleway(
                                                      fontSize: 16,
                                                      color: Color(0xFFE4F4FF),
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
                                                          Navigator.of(context)
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
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            vehicleRef!
                                                                .remove();
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          });
                                                        },
                                                        child: Text(
                                                          "Yes",
                                                          style: GoogleFonts
                                                              .raleway(
                                                            fontSize: 15,
                                                            color: Color(
                                                                0xFFE2C946),
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      )),
                )),
              ),
            );
          } else {
            // Handle the case where the 'users' node or expected data is missing
            return Text('Vehicle data not found.');
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
