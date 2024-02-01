import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

int hexColors(String color) {
  String newColor = '0xff' + color;
  newColor = newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}

class _ForgetPasswordState extends State<ForgetPassword> {
  String errortextemail = '';
  final EmailAdd = TextEditingController();

  @override
  void dispose() {
    EmailAdd.dispose();
    super.dispose();
  }


  void passwordReset(BuildContext context) async {
    if (EmailAdd.text.toString().isEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Please enter your email address!'),
            );
          });
    } else {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: EmailAdd.text.trim());
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('Password reset link sent! Check your email!'),
              );
            });
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        if (e.code == 'user-not-found') {
          // Handle the "user-not-found" error here
          // Display a message to the user
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content:
                      Text("This user not found, please check your email."),
                );
              });
        } else {
          // Handle other FirebaseAuthException errors, if needed
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Text("An error occurred. Please try again later."),
                );
              });
          print('FirebaseAuthException: ${e.code}');
        }
        print(e);
        log('data: $e');
        // showDialog(
        //     context: context,
        //     builder: (context) {
        //       return AlertDialog(
        //         content: Text(e.message.toString()),
        //       );
        //     });
      }
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'FORGOT PASSWORD',
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Raleway",
                  fontWeight: FontWeight.bold),
            ),
            backgroundColor: Color(hexColors('#003459'))),
        body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              'Enter your Email and we will send you a password reset link',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(hexColors('#003459')),
                fontFamily: "Raleway",
                fontSize: 15,
              ),
            ),
          ),

          SizedBox(height: 10),

          //TEXTFIELD FOR EMAIL
          SizedBox(
            width: 370,
            child: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: TextField(
                controller: EmailAdd,
                onChanged: (value) {
                  setState(
                    () {
                      if (value.contains(' ')) {
                        errortextemail = "invalid input blank space detected.";
                      } else if (value.isEmpty) {
                        errortextemail = "Email is required.";
                      } else if (value.length < 10) {
                        errortextemail = "email should atleast 10 character";
                      } else if (!RegExp(
                              r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,}$')
                          .hasMatch(value)) {
                        errortextemail = "Incorrect email detected";
                      } else if (value.isNotEmpty) {
                        errortextemail = "";
                      }
                    },
                  );
                },
                decoration: InputDecoration(
                  counterText: "",
                  errorText: errortextemail.isEmpty ? null : errortextemail,
                  prefixIcon: Icon(Icons.email_outlined,
                      color: Color(hexColors('#003459'))),
                  isDense: true,
                  labelText: 'Email',
                  hintText: 'email@gmail.com',
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

          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              passwordReset(context);
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(150, 34),
              backgroundColor: Color(hexColors('#003459')),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),
            child: Text(
              'Reset Password',
              style: GoogleFonts.raleway(
                fontSize: 15,
                color: Color(0xFFE4F4FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ]));
  }
}
