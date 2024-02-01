import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:parkbai/loginpage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'intro_screens/intro1.dart';
import 'intro_screens/intro2.dart';
import 'intro_screens/intro3.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  //controller to track pages
  final PageController _controller = PageController();

  //keep track if were on te last page
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              onLastPage = (index == 2);
            });
          },
          children: const [
            IntroPage1(),
            IntroPage2(),
            IntroPage3(),
          ],
        ),

        //dot indicators
        Container(
          alignment: const Alignment(0, 0.75),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //skip
              GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(2);
                  },
                  child: Text(
                    'SKIP',
                    style: GoogleFonts.raleway(
                      fontSize: 15,
                      color: Color(0xFF003459),
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              //dot indicator
              SmoothPageIndicator(
                controller: _controller,
                count: 3,
                //axisDirection: Axis.vertical,
                effect: const WormEffect(
                    spacing: 8.0,
                    //radius:  4.0,
                    dotWidth: 24.0,
                    dotHeight: 16.0,
                    paintStyle: PaintingStyle.stroke,
                    strokeWidth: 1.5,
                    dotColor: Color(0xFF003459),
                    activeDotColor: Color(0xFF5aa7cd)),
              ),

              //next or done
              onLastPage
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const LoginPage();
                            },
                          ),
                        );
                      },
                      child: Text(
                        'DONE',
                        style: GoogleFonts.raleway(
                          fontSize: 15,
                          color: Color(0xFF003459),
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                  : GestureDetector(
                      onTap: () {
                        _controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeIn);
                      },
                      child: Text(
                        'NEXT',
                        style: GoogleFonts.raleway(
                          fontSize: 15,
                          color: Color(0xFF003459),
                          fontWeight: FontWeight.bold,
                        ),
                      ))
            ],
          ),
        ),
      ],
    ));
  }
}
