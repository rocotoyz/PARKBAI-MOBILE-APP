import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:grouped_list/grouped_list.dart';
// ignore: unused_import
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:firebase_auth/firebase_auth.dart';


class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _MyAppState();
}


class _MyAppState extends State<HelpCenterPage> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
     //FirebaseAuth.instance.signOut();
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF003459)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            'About/FAQs',
            style: GoogleFonts.raleway(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        elevation: 20,
        backgroundColor: const Color(0xFF00171f),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'images/parkbai_icon.png',
                height: 120, // Adjust the height as needed
                width: 120, // Adjust the width as needed
              ),
              SizedBox(height: 16),
              Text(
                'Welcome to the ParkBai Help Center!',
                style: GoogleFonts.raleway(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Introduction:',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'ParkBai aims to develop an automated parking management system for parking lot owners within Cebu City, Philippines.',
                style: GoogleFonts.raleway(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "How's Your Parking?",
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Sample answer: Our parking system is designed to provide convenience and efficiency to both parking lot owners and drivers.',
                style: GoogleFonts.raleway(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Want to Turn Your Parking Lot into a ParkBai?',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'Contact us to learn how you can integrate ParkBai into your parking facilities and enhance your parking management.',
                style: GoogleFonts.raleway(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
