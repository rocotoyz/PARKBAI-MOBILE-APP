import 'package:flutter/material.dart';

class IntroPage1 extends StatelessWidget {
  const IntroPage1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFe4f4ff),
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 200),
              child: Image.asset(
                'assets/parking-location.gif',
                width: 200,
                height: 200,
              ),
            ),
            const Text(
              'Looking for Parking Locations?',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF003459),
                fontSize: 20,
              ),
            )
          ],
        ),
      ),
    );
  }
}
