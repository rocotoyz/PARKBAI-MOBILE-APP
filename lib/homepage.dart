import 'package:flutter/material.dart';
import 'package:parkbai/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:parkbai/parkingslot.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:parkbai/map.dart';
import 'package:parkbai/paymentpage.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  final User? user = FirebaseAuth.instance.currentUser;
  @override
  State<HomePage> createState() => _HomePageState();
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

TextEditingController searchParkingArea = TextEditingController();
String searchForPark = "";

class StarRating extends StatelessWidget {
  final double averageRating;

  StarRating({required this.averageRating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        double rating = index + 1.0;

        // Use half stars if averageRating is not an exact integer
        if (averageRating >= rating - 0.5 && averageRating < rating) {
          return Icon(
            Icons.star_half,
            color: Colors.amber,
          );
        }

        // Use full stars
        return Icon(
          averageRating >= rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
        );
      }),
    );
  }
}

class ParkingLot {
  final String key;
  final String address;
  final String company;
  final double genAverage;
  final double latitude;
  final double longitude;
  final String parkingLot_layout;
  final int vacantCount;

  ParkingLot(this.key, this.address, this.company, this.genAverage,
      this.latitude, this.longitude, this.parkingLot_layout, this.vacantCount);
}

//HEXCOLOR FOR COLORPALLETE
int hexColor(String color) {
  String newColor = '0xff' + color;
  newColor = newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}

class _HomePageState extends State<HomePage> {
  DatabaseReference? userRef;
  DatabaseReference? ownerReferrence;
  DatabaseReference? lotReferrence;
  Stream? userDataStream;
  Stream? ParkingLotDataStream;

  @override
  void initState() {
    super.initState();
    initializeUserDataStream();
    initializeLotDataStream();
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

  void initializeLotDataStream() {
    ownerReferrence = FirebaseDatabase.instance.ref().child('PARK_OWNER');

    ParkingLotDataStream = ownerReferrence!.onValue;
  }

  // Function to calculate distance using Haversine formula
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Radius of the Earth in kilometers

    // Convert latitude and longitude from degrees to radians
    double lat1Rad = radians(lat1);
    double lon1Rad = radians(lon1);
    double lat2Rad = radians(lat2);
    double lon2Rad = radians(lon2);

    // Calculate differences
    double dLat = lat2Rad - lat1Rad;
    double dLon = lon2Rad - lon1Rad;

    // Haversine formula
    double a = pow(sin(dLat / 2), 2) +
        cos(lat1Rad) * cos(lat2Rad) * pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    // Distance in kilometers
    double distance = earthRadius * c;

    return distance;
  }

  double radians(double degrees) {
    return degrees * pi / 180;
  }

  double currentLatitude = 0.0; // Initialize with a default value
  double currentLongitude = 0.0; // Initialize with a default value

  Future<void> _fetchCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Set the currentLatitude and currentLongitude based on the obtained position
        currentLatitude = position.latitude;
        currentLongitude = position.longitude;
      } else {
        print('Location permission denied');
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
      stream: userDataStream,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          DataSnapshot dataValues = snapshot.data!.snapshot;
          if (dataValues.value != null && dataValues.value is Map) {
            final Map<dynamic, dynamic> userData =
                dataValues.value as Map<dynamic, dynamic>;

            final int? balance = userData['balance']?.toInt();
            return Scaffold(
                appBar: AppBar(
                  elevation: 0,
                  toolbarHeight: 80,
                  centerTitle: false,
                  backgroundColor: const Color(0xFF003459),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Image(
                      width: 40,
                      height: 40,
                      image: AssetImage('images/ParkBai_Transparent.png'),
                    ),
                  ),
                  title: Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4F4FF),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(0, 3),
                            blurRadius: 5,
                            spreadRadius: 0, // Shadow expands
                          ),
                        ],
                      ),
                      child: TextField(
                          controller: searchParkingArea,
                          onChanged: (value) {
                            setState(() {
                              searchForPark = searchParkingArea.text;
                              print(
                                  "Current value of the text input: $searchForPark");
                            });
                          },
                          style: TextStyle(
                            backgroundColor: const Color(0xFFE4F4FF),
                            color: const Color(0xFF003459),
                            fontSize: 18,
                            fontFamily: "Raleway",
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFE4F4FF),
                              prefixIcon: Icon(Icons.search,
                                  size: 40, color: const Color(0xFF003459)),
                              hintText: 'looking for parking area?',
                              hintStyle: TextStyle(
                                fontSize: 18,
                                color: const Color(0xFF003459),
                                fontFamily: "Raleway",
                                fontWeight: FontWeight.bold,
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide:
                                      BorderSide(color: Colors.white)))),
                    ),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 13),
                    child: SingleChildScrollView(
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'LIST OF PARKING LOTS',
                              style: GoogleFonts.raleway(
                                fontSize: 25,
                                color: const Color(0xFFE4F4FF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              height: 350,
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
                                height: 350,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFE2C946),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: StreamBuilder(
                                  stream: ParkingLotDataStream,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData &&
                                        snapshot.data.snapshot.value != null) {
                                      Map<dynamic, dynamic> values =
                                          snapshot.data.snapshot.value;

                                      String query =
                                          searchForPark.toLowerCase();
                                      print(
                                          "Current value of the query input: $searchForPark");
                                      List<ParkingLot> lot = [];

                                      // ignore: unused_local_variable
                                      Set<String> uniqueCompanies = Set();

                                      values.forEach((key, value) async {
                                        if (value['ACCOUNT'] != null &&
                                            value['ACCOUNT']['Application'] !=
                                                null) {
                                          final applicationStatus =
                                              value['ACCOUNT']['Application'];

                                          // Check if the application status is 'ACCEPTED' or 'PENDING'
                                          if (applicationStatus == 'ACCEPTED') {
                                            if (value['PARKING_LOT'] != null) {
                                              final parkingLotData =
                                                  value['PARKING_LOT'];

                                              final parkingAreaData =
                                                  value['PARKING_AREA'];

                                              final address =
                                                  parkingLotData['Address'] ??
                                                      '';
                                              final company =
                                                  parkingLotData['Company'] ??
                                                      '';
                                              final genAverageString =
                                                  value['GenAverage'] ?? '0.0';

                                              final latitude =
                                                  parkingLotData['Latitude'] ??
                                                      0.0;
                                              final longitude =
                                                  parkingLotData['Longitude'] ??
                                                      0.0;
                                              final parkingLot_layout =
                                                  parkingLotData[
                                                          'Profile_Picture'] ??
                                                      '';

                                              // Initialize vacantCount outside the loop
                                              int vacantCount = 0;

                                              // Iterate through parking area keys (like 'A01', 'A02', etc.)
                                              parkingAreaData.forEach(
                                                  (areaKey, areaValue) {
                                                String parkingSpaceStatus =
                                                    areaValue[
                                                            'parking_space'] ??
                                                        '';

                                                // Calculate vacantCount based on parking_space status
                                                if (parkingSpaceStatus ==
                                                    'VACANT') {
                                                  vacantCount++;
                                                }
                                              });

                                              // Now vacantCount should have the correct value
                                              print(
                                                  'Svacant Count for $key: $vacantCount');

                                              // Add ParkingLot once per outer iteration
                                              lot.add(ParkingLot(
                                                key,
                                                address,
                                                company,
                                                double.tryParse(
                                                        genAverageString) ??
                                                    0.0,
                                                latitude,
                                                longitude,
                                                parkingLot_layout,
                                                vacantCount,
                                              ));
                                            }
                                          }
                                        }
                                      });

                                      _fetchCurrentLocation();
                                      lot.sort((a, b) {
                                        double distanceToA = calculateDistance(
                                          a.latitude,
                                          a.longitude,
                                          currentLatitude,
                                          currentLongitude,
                                        );
                                        double distanceToB = calculateDistance(
                                          b.latitude,
                                          b.longitude,
                                          currentLatitude,
                                          currentLongitude,
                                        );
                                        return distanceToA
                                            .compareTo(distanceToB);
                                      });

                                      if (query.isEmpty) {
                                        return ListView.builder(
                                          itemCount: lot.length,
                                          itemBuilder: (context, index) {
                                            final currentLot = lot[index];

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 10, 10, 5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFE4F4FF),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black,
                                                      offset: Offset(0, 1),
                                                      blurRadius: 0,
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                ),
                                                child: ListTile(
                                                  title: Text(
                                                    'COMPANY: ${currentLot.company}',
                                                    style: GoogleFonts.raleway(
                                                      fontSize: 20,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'ADDRESS: ${currentLot.address}',
                                                        style:
                                                            GoogleFonts.raleway(
                                                          fontSize: 15,
                                                          color: const Color(
                                                              0xFF003459),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      // Display GenAverage value as star symbols
                                                      Row(
                                                        children: [
                                                          // Display GenAverage value as star symbols
                                                          StarRating(
                                                              averageRating:
                                                                  currentLot
                                                                      .genAverage),
                                                          SizedBox(width: 4),
                                                          // Display numeric rating value
                                                          Text(
                                                            currentLot
                                                                .genAverage
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .raleway(
                                                              fontSize: 15,
                                                              color: const Color(
                                                                  0xFF003459),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          // Add GPS icon
                                                          GestureDetector(
                                                            onTap: () {
                                                              _fetchCurrentLocation();
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          MapGuide(
                                                                    lotlatitude:
                                                                        currentLot
                                                                            .latitude,
                                                                    lotlongitude:
                                                                        currentLot
                                                                            .longitude,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Icon(
                                                              Icons.location_on,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 4),
                                                      // Display vacantCount
                                                      Text(
                                                        'Vacant Count: ${currentLot.vacantCount}',
                                                        style:
                                                            GoogleFonts.raleway(
                                                          fontSize: 15,
                                                          color: const Color(
                                                              0xFF003459),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ParkingSlot(
                                                          parkingKey:
                                                              currentLot.key,
                                                          parkingLayout: currentLot
                                                              .parkingLot_layout,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        List<ParkingLot> filteredLot = lot
                                            .where((item) => item.company
                                                .toLowerCase()
                                                .contains(query.toLowerCase()))
                                            .toList();
                                        return ListView.builder(
                                          itemCount: query.isEmpty
                                              ? lot.length
                                              : filteredLot.length,
                                          itemBuilder: (context, index) {
                                            final currentLot = query.isEmpty
                                                ? lot[index]
                                                : filteredLot[index];

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 10, 10, 5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFE4F4FF),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black,
                                                      offset: Offset(0, 1),
                                                      blurRadius: 0,
                                                      spreadRadius: 0,
                                                    ),
                                                  ],
                                                ),
                                                child: ListTile(
                                                  title: Text(
                                                    'COMPANY: ${currentLot.company}',
                                                    style: GoogleFonts.raleway(
                                                      fontSize: 20,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'ADDRESS: ${currentLot.address}',
                                                        style:
                                                            GoogleFonts.raleway(
                                                          fontSize: 15,
                                                          color: const Color(
                                                              0xFF003459),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      // Display GenAverage value as star symbols
                                                      Row(
                                                        children: [
                                                          // Display GenAverage value as star symbols
                                                          StarRating(
                                                              averageRating:
                                                                  currentLot
                                                                      .genAverage),
                                                          SizedBox(width: 4),
                                                          // Display numeric rating value
                                                          Text(
                                                            currentLot
                                                                .genAverage
                                                                .toString(),
                                                            style: GoogleFonts
                                                                .raleway(
                                                              fontSize: 15,
                                                              color: const Color(
                                                                  0xFF003459),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          // Add GPS icon
                                                          GestureDetector(
                                                            onTap: () {
                                                              _fetchCurrentLocation();
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          MapGuide(
                                                                    lotlatitude:
                                                                        currentLot
                                                                            .latitude,
                                                                    lotlongitude:
                                                                        currentLot
                                                                            .longitude,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Icon(
                                                              Icons.location_on,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 4),
                                                      // Display vacantCount
                                                      Text(
                                                        'Vacant Count: ${currentLot.vacantCount}',
                                                        style:
                                                            GoogleFonts.raleway(
                                                          fontSize: 15,
                                                          color: const Color(
                                                              0xFF003459),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            ParkingSlot(
                                                          parkingKey:
                                                              currentLot.key,
                                                          parkingLayout: currentLot
                                                              .parkingLot_layout,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    } else {
                                      return Center(
                                        child: Text(
                                          "No Parking lot available!",
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
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Container(
                                height: 110,
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
                                  height: 110,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    image: const DecorationImage(
                                      image: AssetImage('images/Ads.png'),
                                      fit: BoxFit.cover,
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFFE2C946),
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Container(
                                height: 105,
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
                                  height: 105,
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
                                        padding:
                                            EdgeInsets.fromLTRB(0, 5, 0, 5),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            '₱ ${balance}.00',
                                            style: GoogleFonts.raleway(
                                              fontSize: 40,
                                              color: const Color(0xFFE4F4FF),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 2,
                                        width: 300,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0xFF5AA7CD),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      GestureDetector(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'CASH IN',
                                            style: GoogleFonts.raleway(
                                              fontSize: 22,
                                              color: const Color(0xFFE4F4FF),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            goingLeftPageRoute(
                                                nextPage: PaymentPage()),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ));
          } else {
            // Handle the case where the 'users' node or expected data is missing
            return Text('User data not found. ${userUID}');
          }
        } else if (snapshot.hasError) {
          print(userUID);
          return Text('Error: ${snapshot.error}');
        } else {
          return Text('Loading...');
        }
      });
}
