import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkbai/loginpage.dart';
import 'package:parkbai/onboarding_screen.dart';
import 'package:parkbai/vehicle.dart';
import 'package:parkbai/vehicleinfo.dart';
import 'package:parkbai/accountsetting.dart';
import 'dart:math';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      child: Text(
        'SIGN OUT',
        style: GoogleFonts.raleway(
          fontSize: 15,
          color: Color(0xFFE4F4FF),
          fontWeight: FontWeight.bold,
        ),
      ),
      decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            //darker shadow of button right
            BoxShadow(
              color: Colors.grey.shade500,
              offset: Offset(6, 6),
              blurRadius: 15,
              spreadRadius: 1,
            )
          ]),
    );
  }
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

class Vehicle {
  final String key;
  final String brand;
  final String platenumber;
  final String status;

  Vehicle(this.key, this.brand, this.platenumber, this.status);
}

class _ProfilePageState extends State<ProfilePage> {
  DatabaseReference? DriverDataref;
  DatabaseReference? userRef;
  Stream? userDataStream;

  DatabaseReference? VehicleRef;
  Stream? VehicleDataStream;

  DatabaseReference? driverToAdminref;

  @override
  void initState() {
    super.initState();
    initializeUserDataStream();
    initializeVehicleDataStream();
  }

  void initializeUserDataStream() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userRef = FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(user.uid)
          .child('ACCOUNT');

      userDataStream = userRef!.onValue;
    }
  }

  void initializeVehicleDataStream() {
    final User? vehicle = FirebaseAuth.instance.currentUser;
    if (vehicle != null) {
      VehicleRef = FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(vehicle.uid)
          .child('VEHICLE');

      VehicleDataStream = VehicleRef!.onValue;
    }
  }

  void signOut(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: Duration(milliseconds: 10),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, a1, a2, widget) {
        // ignore: unused_local_variable
        double screenWidth = MediaQuery.of(context).size.width;

        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
            child: AlertDialog(
              backgroundColor: Color(hexColor('#003459')),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              title: Center(
                child: Column(
                  children: [
                    Text(
                      "Do you want to sign out?", 
                      style: GoogleFonts.raleway(
                        fontSize: 17, // Adjusted font size
                        color: Color(0xFFE4F4FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 3), // Adjusted padding
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.raleway(
                              fontSize: 15, // Adjusted font size
                              color: Color(0xFFE2C946),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              FirebaseAuth.instance.signOut();
                              username.clear();
                              password.clear();
                              // Close the existing stream and set it to null
                              userDataStream = null;
                              userRef = null;
                            });
                            showSnackBar(context, "Successfully signed out.");
                            // Redirect to the OnBoardingScreen
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OnBoardingScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: Text(
                            "Yes",
                            style: GoogleFonts.raleway(
                              fontSize: 15, // Adjusted font size
                              color: Color(0xFFE2C946),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void RFIDrequest(BuildContext context) async {
    final User? DriverData = FirebaseAuth.instance.currentUser;
    if (DriverData != null) {
      DriverDataref = FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(DriverData.uid)
          .child('ACCOUNT');

      DatabaseEvent event = await DriverDataref!.once();
      if (event.snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null && data['license'] != null) {
          String fname = data['firstname'].toString();
          String mname = data['middlename'].toString();
          String lname = data['lastname'].toString();
          String email = data['email'].toString();
          // String address = data['address'].toString();
          double balance = double.parse(data['balance'].toString());
          print('Current Balance: $balance');

          DateTime now = DateTime.now();
          // ignore: unused_element
          final formattedDate = DateFormat('dd/MM/yyyy').format(now);

          DateTime now3 = DateTime.now();
          String formattedDate3 = DateFormat('HH:mm:ss').format(now3);

          int generateRandomNumber() {
            Random random = Random();
            int min = 100000000; // Smallest 9-digit number
            int max = 999999999; // Largest 9-digit number
            return min + random.nextInt(max - min);
          }

          int randomNum = generateRandomNumber();
          print(randomNum);

          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: '',
            transitionDuration: Duration(milliseconds: 250),
            pageBuilder: (context, animation1, animation2) {
              return Container();
            },
            transitionBuilder: (context, a1, a2, widget) {
              // ignore: unused_local_variable
              double screenWidth = MediaQuery.of(context).size.width;

              return ScaleTransition(
                scale: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0.5, end: 1.0).animate(a1),
                  child: AlertDialog(
                    backgroundColor: Color(hexColor('#003459')),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              "We will send you an email once your rfid request is approve.",
                              style: GoogleFonts.raleway(
                                fontSize: 15, // Adjusted font size
                                color: Color(0xFFE2C946),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            "Do you want to continue?",
                            style: GoogleFonts.raleway(
                              fontSize: 17, // Adjusted font size
                              color: Color(0xFFE4F4FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 3), // Adjusted padding
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.raleway(
                                    fontSize: 15, // Adjusted font size
                                    color: Color(0xFFE2C946),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    if (balance < 150) {
                                      showSnackBar(context,
                                          "sorry, you dont have enough balance, rfid card price is 150.00 php.");
                                    } else {
                                      final User? DRrequestToAdmin =
                                          FirebaseAuth.instance.currentUser;
                                      if (DRrequestToAdmin != null) {
                                        driverToAdminref = FirebaseDatabase
                                            .instance
                                            .ref()
                                            .child('DRIVER')
                                            .child(DRrequestToAdmin.uid)
                                            .child('RFID_REQUEST');

                                        Map<dynamic, dynamic>
                                            pushToAdminrfidrequest = {
                                          'request_date':
                                              formattedDate.toString(),
                                          'type': 'rfid-request',
                                          'ref_number': randomNum,
                                          'Account_Email': email,
                                          'Account_Fname': fname,
                                          'Account_Mname': mname,
                                          'Account_Lname': lname,
                                          'Account_ID': DRrequestToAdmin.uid,
                                          'Amount': 150,
                                          'Reference_Number': randomNum,
                                          'Release_Date': '',
                                          'Request_Date': formattedDate,
                                          'Release_Status': 'PENDING',
                                          'Request_Time': formattedDate3
                                        };
                                        driverToAdminref
                                            ?.push()
                                            .set(pushToAdminrfidrequest);
                                      }
                                          showSnackBar(context,
                                        "your request send succesfully.");
                                    Navigator.of(context).pop();
                                    }
                                
                                  });
                                },
                                child: Text(
                                  "Yes",
                                  style: GoogleFonts.raleway(
                                    fontSize: 15, // Adjusted font size
                                    color: Color(0xFFE2C946),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: userDataStream,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            DataSnapshot dataValues = snapshot.data!.snapshot;
            // Check if the 'users' node exists in the database
            if (dataValues.value != null && dataValues.value is Map) {
              final Map<dynamic, dynamic> userData =
                  dataValues.value as Map<dynamic, dynamic>;
              // Retrieve data safely
              final String? imageurl = userData['imageUrl']?.toString();
              final String? imageDLurl = userData['imageDLUrl']?.toString();
              final String? fname = userData['firstname']?.toString();
              final String? mname = userData['middlename']?.toString();
              final String? lname = userData['lastname']?.toString();
              final String? email = userData['email']?.toString();
              final String? phonenumber = userData['phonenumber']?.toString();
              final String? status = userData['status']?.toString();
              final String? address = userData['address']?.toString();
              // final int? balance = userData['balance']?.toInt();

              return Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 80),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE4F4FF),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(0, 3),
                                  blurRadius: 5,
                                  spreadRadius: 0, // Shadow expands
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(15, 10, 0, 0),
                                  child: CircleAvatar(
                                    radius: 40.0,
                                    backgroundImage:
                                        NetworkImage('${imageurl}'),
                                    backgroundColor: Colors.transparent,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15, 15, 15, 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hello, ${fname ?? "N/A"}',
                                        style: GoogleFonts.raleway(
                                          fontSize: 28,
                                          color: Color(0xFF003459),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'status: ${status ?? "N/A"}',
                                            style: GoogleFonts.raleway(
                                              fontSize: 15,
                                              color: Color(0xFF003459),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // Icon(
                                          //   Icons.check_circle,
                                          //   size: 17,
                                          //   color: Color(0xFFE2C946),
                                          // )
                                        ],
                                      ),
                                      Text(
                                        'Email: ${email ?? "N/A"}',
                                        style: GoogleFonts.raleway(
                                          fontSize: 15,
                                          color: Color(0xFF003459),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 0, 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'PERSONAL',
                              style: GoogleFonts.raleway(
                                fontSize: 17,
                                color: Color(0xFFE4F4FF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.settings),
                              color: Color(0xFFE2C946),
                              iconSize: 23, // Choose the icon you want
                              onPressed: () {
                                print('button pressed');
                              },
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        child: Container(
                          height: 240,
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
                            height: 240,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE2C946),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 10, 0, 0),
                                      child: Text(
                                        'Driver License: ',
                                        style: GoogleFonts.raleway(
                                          fontSize: 15,
                                          color: Color(0xFFE2C946),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(15, 10, 0, 0),
                                      child: Container(
                                        width: 120.0,
                                        height: 77.0,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          image: DecorationImage(
                                            image:
                                                NetworkImage('${imageDLurl}'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 10, 5),
                                  child: Row(
                                    children: [
                                      Text(
                                        'FULLNAME: ',
                                        style: GoogleFonts.raleway(
                                          fontSize: 15,
                                          color: Color(0xFFE2C946),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${fname} ${lname}, ${mname}',
                                        style: GoogleFonts.raleway(
                                          fontSize: 15,
                                          color: Color(0xFFE4F4FF),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 10, 5),
                                  child: Row(
                                    children: [
                                      Text(
                                        'ADDRESS: ',
                                        style: GoogleFonts.raleway(
                                          fontSize: 15,
                                          color: Color(0xFFE2C946),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${address}',
                                        style: GoogleFonts.raleway(
                                          fontSize: 15,
                                          color: Color(0xFFE4F4FF),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 10, 5),
                                  child: Row(
                                    children: [
                                      Text(
                                        'PHONE NUMBER: ',
                                        style: GoogleFonts.raleway(
                                          fontSize: 15,
                                          color: Color(0xFFE2C946),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${phonenumber}',
                                        style: GoogleFonts.raleway(
                                          fontSize: 15,
                                          color: Color(0xFFE4F4FF),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(20, 10, 10, 5),
                                  child: Row(
                                    children: [
                                      Text(
                                        'EMAIL: ',
                                        style: GoogleFonts.raleway(
                                          fontSize: 15,
                                          color: Color(0xFFE2C946),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${email}',
                                        style: GoogleFonts.raleway(
                                          fontSize: 15,
                                          color: Color(0xFFE4F4FF),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => accountSetting(),
                          //   ),
                          // );
                          Navigator.push(
                            context,
                            goingTopPageRoute(nextPage: accountSetting()),
                          );
                          print("ma edit sha");
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 0, 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'VEHICLE',
                              style: GoogleFonts.raleway(
                                fontSize: 17,
                                color: Color(0xFFE4F4FF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.drive_eta_rounded),
                              color: Color(0xFFE2C946),
                              iconSize: 23, // Choose the icon you want
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  goingTopPageRoute(nextPage: AddVehicle()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 200,
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
                            height: 200,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE2C946),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: StreamBuilder(
                                stream: VehicleDataStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data.snapshot.value != null) {
                                    Map<dynamic, dynamic> values =
                                        snapshot.data.snapshot.value;
                                    List<Vehicle> vehicles = [];
                                    values.forEach((key, value) {
                                      final brand = value['brand'] ?? '';
                                      final platenumber =
                                          value['platenumber'] ?? '';
                                      final status = value['status'] ?? '';
                                      vehicles.add(Vehicle(
                                          key, brand, platenumber, status));
                                    });
                                    return ListView.builder(
                                      itemCount: vehicles.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              2, 15, 2, 5),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Color(hexColor('#003459')),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black,
                                                  offset: Offset(0, 1),
                                                  blurRadius: 0,
                                                  spreadRadius:
                                                      0, // Shadow expands
                                                ),
                                              ],
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                vehicles[index].brand,
                                                style: GoogleFonts.raleway(
                                                  fontSize: 15,
                                                  color: Color(0xFFE2C946),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Text(
                                                vehicles[index].platenumber,
                                                style: GoogleFonts.raleway(
                                                  fontSize: 15,
                                                  color: Color(0xFFE4F4FF),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              trailing: Text(
                                                vehicles[index].status,
                                                style: GoogleFonts.raleway(
                                                  fontSize: 15,
                                                  color: Color(0xFFE4F4FF),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  goingTopPageRoute(
                                                    nextPage: VehicleInfo(
                                                      vehicleKey:
                                                          vehicles[index].key,
                                                    ),
                                                  ),
                                                );

                                                // Navigator.push(
                                                //   context,
                                                //   MaterialPageRoute(
                                                //     builder: (context) =>
                                                //         VehicleInfo(
                                                //       vehicleKey:
                                                //           vehicles[index].key,
                                                //     ),
                                                //   ),
                                                // );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    return Center(
                                      child: Text(
                                        "To provide your RFID card, add your vehicle first.",
                                        style: GoogleFonts.raleway(
                                          fontSize: 15,
                                          color: Color(0xFFE4F4FF),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }
                                })),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 25, 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              child: Text(
                                'RFID REQUEST?',
                                style: GoogleFonts.raleway(
                                  fontSize: 17,
                                  color: Color(0xFFE4F4FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onTap: () {
                                RFIDrequest(context);
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 40,
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
                          height: 40,
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
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    InkWell(
                                      child: Text(
                                        'Did you lost your rfid card?',
                                        style: GoogleFonts.raleway(
                                          fontSize: 15,
                                          color: Color(0xFFE2C946),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ElevatedButton(
                          child: Row(
                            children: [
                              Icon(Icons.logout_outlined),
                              SizedBox(width: 8),
                              Text(
                                'SIGN OUT',
                                style: GoogleFonts.raleway(
                                  fontSize: 15,
                                  color: Color(0xFFE4F4FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            signOut(context);
                            FirebaseAuth.instance
                                .idTokenChanges()
                                .listen((User? user) {
                              if (user == null) {
                                print('User is currently signed out!');
                              } else {
                                print('User is signed in!');
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 34),
                            backgroundColor: Color(hexColor('#003459')),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            shadowColor: Colors.white, // Color of the shadow
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // Handle the case where the 'users' node or expected data is missing
              return Text('User data not found. ${userUID}');
            }
          } else if (snapshot.hasError) {
            print(userUID);
            return Text('Error: ${snapshot.error}');
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
}
