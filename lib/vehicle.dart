import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
// ignore: unused_import
import 'package:parkbai/createpage.dart';

class AddVehicle extends StatefulWidget {
  const AddVehicle({Key? key}) : super(key: key);

  @override
  AddVehicleState createState() => AddVehicleState();
}

//HEXCOLOR FOR COLORPALLETE
int hexColor(String color) {
  String newColor = '0xff' + color;
  newColor = newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}

class AddVehicleState extends State<AddVehicle> {
  DatabaseReference? AddVehicleRef;
  Stream? AddVehicleDataStream;

  String vehicleImage = " ";
  String vehicleDocument = " ";
  TextEditingController platenumber = TextEditingController();
  TextEditingController vehicleType = TextEditingController();
  TextEditingController vehicleColor = TextEditingController();
  TextEditingController vehicleBrand = TextEditingController();
  TextEditingController vehicleModel = TextEditingController();

  String errortextplatenumber = '';
  String errortextvehicleType = '';
  String errortextvehicleBrand = '';
  String errortextvehicleModel = '';
  String errortextvehicleColor = '';

  void checkInputtedVehicleData() {}

  void AddVehicle() {
    final User? VehicleRef = FirebaseAuth.instance.currentUser;
    if (VehicleRef != null) {
      AddVehicleRef = FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(VehicleRef.uid)
          .child('VEHICLE')
          .child(platenumber.text);

      Map<String, String> vehicles = {
        'vehicle_app': "PENDING",
        'vehicleDocument': vehicleDocument,
        'vehicleImage': vehicleImage,
        'platenumber': platenumber.text.toString().toUpperCase(),
        'brand': vehicleBrand.text.toString().toUpperCase(),
        'type': vehicleType.text.toString().toUpperCase(),
        'model': vehicleModel.text.toString().toUpperCase(),
        'color': vehicleColor.text.toString().toUpperCase(),
        'status': "---",
      };
      AddVehicleRef?.set(vehicles);
    }
  }

  void UploadVehicleImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    // Check if the selected file has a specific extension (e.g., jpg or png)
    List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];
    String fileExtension = image.path.split('.').last.toLowerCase();

    if (!allowedExtensions.contains(fileExtension)) {
      // Display an error message or handle the case where the selected file has an invalid extension
      print('Invalid file extension. Please select a valid image file.');
      return;
    }

    String VehicleimageName = DateTime.now().millisecondsSinceEpoch.toString();
    String fileType = 'image';

    Reference ref = FirebaseStorage.instance
        .ref()
        .child("DRIVER")
        .child("VEHICLE")
        .child('$VehicleimageName.$fileExtension');

    // Specify custom metadata with dynamically determined file type
    SettableMetadata metadata = SettableMetadata(
      contentType:
          'image/$fileExtension', // Set the content type based on the file extension
      customMetadata: {
        'fileType': fileType,
        'extension': fileExtension
      }, // You can add more metadata as needed
    );

    try {
      // Upload the file with custom metadata
      await ref.putFile(File(image.path), metadata);

      // Get the download URL
      await ref.getDownloadURL().then((value) {
        setState(() {
          vehicleImage = value;
        });
      });
    } catch (error) {
      print("Error uploading vehicle image: $error");
      // Handle the error as needed
    }
  }

  void UploadVehicleDocument() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return;

    // Check if the selected file has a specific extension (e.g., jpg or png)
    List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];
    String fileExtension = image.path.split('.').last.toLowerCase();

    if (!allowedExtensions.contains(fileExtension)) {
      // Display an error message or handle the case where the selected file has an invalid extension
      print('Invalid file extension. Please select a valid image file.');
      return;
    }

    String vehicleDocumentname =
        DateTime.now().millisecondsSinceEpoch.toString();
    String fileType = 'image';

    Reference ref = FirebaseStorage.instance
        .ref()
        .child("DRIVER")
        .child("VEHICLE")
        .child("DOCUMENTS")
        .child('$vehicleDocumentname.$fileExtension');

    // Specify custom metadata with dynamically determined file type
    SettableMetadata metadata = SettableMetadata(
      contentType:
          'image/$fileExtension', // Set the content type based on the file extension
      customMetadata: {
        'fileType': fileType,
        'extension': fileExtension
      }, // You can add more metadata as needed
    );

    try {
      // Upload the file with custom metadata
      await ref.putFile(File(image.path), metadata);

      // Get the download URL
      await ref.getDownloadURL().then((value) {
        setState(() {
          vehicleDocument = value;
        });
      });
    } catch (error) {
      print("Error uploading vehicle document: $error");
      // Handle the error as needed
    }
  }

  //CLEAR ALL INPUT IN TEXTFIELD AFTER SUBMIT
  // void clearInput() {
  //   platenumber.clear();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(hexColor('#003459')),
      appBar: AppBar(
        centerTitle: true,
        title: Text('VEHICLE REGISTRATION',
            style: GoogleFonts.raleway(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        elevation: 20,
        backgroundColor: Color(hexColor('#003459')),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          height: 1113,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 3))
              ]),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  UploadVehicleImage();
                },
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 370,
                      height: 200,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        color: Colors.grey,
                      ),
                      child: Center(
                        child: vehicleImage == " "
                            ? Icon(
                                Icons.add,
                                size: 60,
                                color: Color(hexColor('#003459')),
                              )
                            : Image.network(vehicleImage),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'add a photo of your vehicle',
                        style: TextStyle(
                          color: Color(hexColor('#003459')),
                          fontSize: 15,
                          fontFamily: "Raleway",
                        ),
                      ),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  UploadVehicleDocument();
                },
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 370,
                      height: 200,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        color: Colors.grey,
                      ),
                      child: Center(
                        child: vehicleDocument == " "
                            ? Icon(
                                Icons.add,
                                size: 60,
                                color: Color(hexColor('#003459')),
                              )
                            : Image.network(vehicleDocument),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'add a photo of your vehicle OR/CR',
                        style: TextStyle(
                          color: Color(hexColor('#003459')),
                          fontSize: 15,
                          fontFamily: "Raleway",
                        ),
                      ),
                    )
                  ],
                ),
              ),
              //TEXTFIELD FOR PLATENUMBER
              SizedBox(
                width: 370,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: TextField(
                    maxLength: 15,
                    controller: platenumber,
                    onChanged: (value) {
                      setState(() {
                        if (value.contains(' ')) {
                          errortextplatenumber =
                              "invalid input blank space detected.";
                        } else if (value.isEmpty) {
                          errortextplatenumber = "platenumber is required.";
                        } else if (value.length < 3) {
                          errortextplatenumber = "Platenumber invalid format";
                        } else if (value.isNotEmpty) {
                          errortextplatenumber = "";
                        }
                      });
                    },
                    decoration: InputDecoration(
                      filled:
                          true, // Set to true to enable filling the background
                      fillColor: Colors.white,
                      counterText: "",
                      errorText: errortextplatenumber.isEmpty
                          ? null
                          : errortextplatenumber,
                      prefixIcon: Icon(Icons.app_registration_sharp,
                          color: Color(hexColor('#003459'))),
                      isDense: true,
                      labelText: 'Platenumber',
                      hintText: 'xxxx-xxxxxxx',
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontFamily: "Raleway",
                      ),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.white)),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              //TEXTFIELD FOR VEHICLE BRAND
              SizedBox(
                width: 370,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: TextField(
                    maxLength: 15,
                    controller: vehicleBrand,
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          errortextvehicleBrand = "platenumber is required.";
                        } else if (value.length < 3) {
                          errortextvehicleBrand = "Platenumber invalid format";
                        } else if (value.isNotEmpty) {
                          errortextvehicleBrand = "";
                        }
                      });
                    },
                    decoration: InputDecoration(
                      filled:
                          true, // Set to true to enable filling the background
                      fillColor: Colors.white,
                      counterText: "",
                      errorText: errortextvehicleBrand.isEmpty
                          ? null
                          : errortextvehicleBrand,
                      prefixIcon: Icon(Icons.branding_watermark_outlined,
                          color: Color(hexColor('#003459'))),
                      isDense: true,
                      labelText: 'vehicle brand',
                      hintText: 'xxxxxx',
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontFamily: "Raleway",
                      ),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.white)),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              //TEXTFIELD FOR VEHICLE TYPE
              SizedBox(
                width: 370,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: TextField(
                    maxLength: 15,
                    controller: vehicleType,
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          errortextvehicleType = "vehicle type is required.";
                        } else if (value.length < 3) {
                          errortextvehicleType = "vehicle type invalid format";
                        } else if (value.isNotEmpty) {
                          errortextvehicleType = "";
                        }
                      });
                    },
                    decoration: InputDecoration(
                      filled:
                          true, // Set to true to enable filling the background
                      fillColor: Colors.white,
                      counterText: "",
                      errorText: errortextvehicleType.isEmpty
                          ? null
                          : errortextvehicleType,
                      prefixIcon: Icon(Icons.car_repair_outlined,
                          color: Color(hexColor('#003459'))),
                      isDense: true,
                      labelText: 'vehicle type',
                      hintText: 'xxxxxx',
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontFamily: "Raleway",
                      ),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.white)),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              //TEXTFIELD FOR VEHICLE COLOR
              SizedBox(
                width: 370,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: TextField(
                    maxLength: 15,
                    controller: vehicleColor,
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          errortextvehicleColor = "vehicle color is required.";
                        } else if (value.length < 2) {
                          errortextvehicleColor =
                              "vehicle color invalid format";
                        } else if (value.isNotEmpty) {
                          errortextvehicleColor = "";
                        }
                      });
                    },
                    decoration: InputDecoration(
                      filled:
                          true, // Set to true to enable filling the background
                      fillColor: Colors.white,
                      counterText: "",
                      errorText: errortextvehicleColor.isEmpty
                          ? null
                          : errortextvehicleColor,
                      prefixIcon: Icon(Icons.color_lens_outlined,
                          color: Color(hexColor('#003459'))),
                      isDense: true,
                      labelText: 'vehicle color',
                      hintText: 'purple',
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontFamily: "Raleway",
                      ),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.white)),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              //TEXTFIELD FOR VEHICLE MODEL
              SizedBox(
                width: 370,
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: TextField(
                    maxLength: 15,
                    controller: vehicleModel,
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          errortextvehicleModel = "vehicle color is required.";
                        } else if (value.length < 2) {
                          errortextvehicleModel =
                              "vehicle color invalid format";
                        } else if (value.isNotEmpty) {
                          errortextvehicleModel = "";
                        }
                      });
                    },
                    decoration: InputDecoration(
                      filled:
                          true, // Set to true to enable filling the background
                      fillColor: Colors.white,
                      counterText: "",
                      errorText: errortextvehicleModel.isEmpty
                          ? null
                          : errortextvehicleModel,
                      prefixIcon: Icon(Icons.category_rounded,
                          color: Color(hexColor('#003459'))),
                      isDense: true,
                      labelText: 'vehicle model',
                      hintText: 'vehicle model',
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontFamily: "Raleway",
                      ),
                      border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(color: Colors.white)),
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(150, 34),
                      backgroundColor: Color(hexColor('#003459')),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    child: Text(
                      "SUBMIT",
                      style: GoogleFonts.raleway(
                        fontSize: 15,
                        color: Color(0xFFE4F4FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      if (platenumber.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "please add your platenumber.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 5,
                          backgroundColor: Color(hexColor('#003459')),
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else if (vehicleBrand.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "please add your vehicle brand.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 5,
                          backgroundColor: Color(hexColor('#003459')),
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else if (vehicleType.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "please add your vehicle type.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 5,
                          backgroundColor: Color(hexColor('#003459')),
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else if (vehicleColor.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "please add your vehicle color.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 5,
                          backgroundColor: Color(hexColor('#003459')),
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else if (vehicleModel.text.isEmpty) {
                        Fluttertoast.showToast(
                          msg: "please add your vehicle model.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 5,
                          backgroundColor: Color(hexColor('#003459')),
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                      } else {
                        AddVehicle();
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
