import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:parkbai/homepage.dart';
import 'package:parkbai/onboarding_screen.dart';
import 'package:parkbai/profile.dart';
import 'package:parkbai/parkinghistory.dart';
import 'package:parkbai/helpcenter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Stripe.publishableKey = "pk_test_51OCYp2FyV5ZDVY2DEA6QoZVPJpEJElLhfXDxTOHubictDSq3deGDfMkiTPAxbmYGcbpP0tirlmAaG7WPhcYOlZmi00mGLTJ3Jz";
  runApp(const MyApp());


}


class MyApp extends StatefulWidget {
  const MyApp({Key? key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance
            .authStateChanges()
            .map((user) => user == null ? null : user),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MainPage();
          } else {
            return OnBoardingScreen();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF003459)),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage();

  @override
  State<MainPage> createState() => _MainPageState();
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

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    ProfilePage(),
    ParkingHistory(),
    HelpCenterPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            backgroundColor: const Color(0xFF00171F),
            color: Colors.white,
            activeColor: const Color(0xFFE2C946),
            gap: 10,
            iconSize: 20,
            tabs: [
              GButton(
                icon: Icons.local_parking,
                text: 'PARKING',
                textStyle: GoogleFonts.raleway(
                  fontSize: 15,
                  color: Color(0xFFE4F4FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              GButton(
                icon: Icons.person,
                text: 'ACCOUNT',
                textStyle: GoogleFonts.raleway(
                  fontSize: 15,
                  color: Color(0xFFE4F4FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              GButton(
                icon: Icons.history,
                text: 'HISTORY',
                textStyle: GoogleFonts.raleway(
                  fontSize: 15,
                  color: Color(0xFFE4F4FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              GButton(
                icon: Icons.support_agent,
                text: 'ASK HELP?',
                textStyle: GoogleFonts.raleway(
                  fontSize: 15,
                  color: Color(0xFFE4F4FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
