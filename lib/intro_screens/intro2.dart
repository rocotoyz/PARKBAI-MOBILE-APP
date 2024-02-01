import 'package:flutter/material.dart';

class IntroPage2 extends StatelessWidget {
  const IntroPage2({Key? key}) : super(key: key);

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
                'assets/parking1.gif',
                width: 200,
                height: 200,
              ),
            ),
            const Text(
              'Want to have hassle-free parking experience?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF003459),
                fontSize: 20,
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}
