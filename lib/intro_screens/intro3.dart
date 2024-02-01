import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:gif_view/gif_view.dart';


class IntroPage3 extends StatelessWidget {
  const IntroPage3({Key? key}) : super(key: key);

  @override
 Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFe4f4ff),
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 200),
              child: GifView.asset('assets/parkbai_logo.gif',
              frameRate: 15)
            ),
            const Text(
              'Worry no more! Welcome to ParkBai!',
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
