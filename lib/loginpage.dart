import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parkbai/createpage.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:parkbai/main.dart';
import 'package:parkbai/forgotpassword.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _MyHomePageState();
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

final username = TextEditingController();
final password = TextEditingController();

//USER SIGN IN
void userSignin(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) {
      return Center(
        child: CircularProgressIndicator(
          color: Color(hexColor('#003459')),
          backgroundColor: Colors.white,
        ),
      );
    },
  );

  // CHECK USERNAME AND PASSWORD
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: username.text.toLowerCase().trim(),
      password: password.text.toLowerCase().trim(),
    );
    Navigator.pop(context); // Close the dialog
    // Redirect to the main page
    Navigator.push(
      context,
      goingLeftPageRoute(nextPage: MainPage()),
    );
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context); // Close the dialog

    if (e.code == 'user-not-found') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Incorrect Email."),
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
    } else if (e.code == 'wrong-password') {
      IncorrectPassword(context);
    }
  }
}

//REDIRECT TO CREATE ACCOUNT PAGE
void RedirectCreateAccount(BuildContext context) {
  Navigator.push(
    context,
    goingTopPageRoute(nextPage: CreateAccount()),
  );
}

//ERROR MESSAGE OF INCORRECT EMAIL

void IncorrectEmail(BuildContext context) {

}

//ERROR MESSAGE OF INCORRECT PASSWORD
void IncorrectPassword(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Incorrect Password.",
              style: TextStyle(color: Color(0xFF003459)),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                // ignore: deprecated_member_use
                primary: Color(0xFF003459),
              ),
              child: Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    },
  );
}

final User? user = FirebaseAuth.instance.currentUser;
String userUID = user!.uid;

class _MyHomePageState extends State<LoginPage> {
  bool showpass = true;
  String errortextuser = '';
  String errortextpass = '';

  // @override
  // void dispose() {
  //   username.dispose();
  //   password.dispose();
  //   super.dispose();
  // }

  //HEXCOLOR FOR COLORPALLETE
  int hexColor(String color) {
    String newColor = '0xff' + color;
    newColor = newColor.replaceAll('#', '');
    int finalColor = int.parse(newColor);
    return finalColor;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Color(hexColor('#003459')),
            body: Column(
              children: [
                Stack(
                  children: [
                    Center(
                      child: Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 130),
                        width: MediaQuery.of(context).size.width,
                        height: 430,
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Column(children: [
                            Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: Text(
                                  'WELCOME!',
                                  style: TextStyle(
                                      color: Color(hexColor('#003459')),
                                      fontSize: 51,
                                      fontFamily: "Raleway",
                                      fontWeight: FontWeight.bold),
                                )),

                            //TEXTFIELD FOR EMAIL
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextField(
                                controller: username,
                                onChanged: (value) {
                                  setState(() {
                                    if (value.contains(' ')) {
                                      errortextuser =
                                          "Invalid input: Blank space detected.";
                                    } else if (value.isEmpty) {
                                      errortextuser = "Email is required.";
                                    } else if (!RegExp(
                                            r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,}$')
                                        .hasMatch(value)) {
                                      errortextuser =
                                          "Incorrect email detected";
                                    } else if (value.isNotEmpty) {
                                      errortextuser = "";
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  errorText: errortextuser.isEmpty
                                      ? null
                                      : errortextuser,
                                  prefixIcon: Icon(Icons.email_outlined,
                                      color: Color(hexColor('#003459'))),
                                  isDense: true,
                                  labelText: 'Email',
                                  hintText: 'email@gmail.com',
                                  labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Raleway",
                                  ),
                                  border: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                ),
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),

                            //TEXTFIELD FOR PASSWORD
                            Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextField(
                                controller: password,
                                obscureText: showpass,
                                onChanged: (value) {
                                  setState(() {
                                    if (value.contains(' ')) {
                                      errortextpass =
                                          "invalid input blank space detected.";
                                    } else if (value.isEmpty) {
                                      errortextpass = "password is required.";
                                    } else if (value.isNotEmpty) {
                                      errortextpass = "";
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  errorText: errortextpass.isEmpty
                                      ? null
                                      : errortextpass,
                                  prefixIcon: Icon(Icons.lock,
                                      color: Color(hexColor('#003459'))),
                                  suffixIcon: IconButton(
                                    icon: showpass
                                        ? Icon(
                                            Icons.visibility,
                                            color: Color(hexColor('#003459')),
                                          )
                                        : Icon(
                                            Icons.visibility_off_outlined,
                                            color: Color(hexColor('#003459')),
                                          ),
                                    onPressed: () {
                                      setState(() {
                                        showpass = !showpass;
                                      });
                                    },
                                  ),
                                  isDense: true,
                                  labelText: 'Password',
                                  labelStyle: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Raleway",
                                  ),
                                  border: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                      borderSide:
                                          BorderSide(color: Colors.white)),
                                ),
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3, left: 150),
                              child: InkWell(
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: Color(hexColor('#003459')),
                                    fontFamily: "Raleway",
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ForgetPassword()),
                                  );
                                },
                              ),
                            ),

                            // BUTTON TO LOG IN THE USER ACCOUNT
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  // setState(() {
                                  // if (username.text.toLowerCase() == "") {
                                  //   errortextuser = "username is required.";
                                  // } else if (password.text.toLowerCase() ==
                                  //     "") {
                                  //   errortextpass = "password is required.";
                                  // }
                                  // // ignore: unrelated_type_equality_checks
                                  // else if (RegExp(
                                  //           r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$') !=
                                  //       (username.text)) {
                                  //     errortextuser = "invalid email detected.";
                                  //   } else {
                                  userSignin(context);
                                  //}
                                  // });
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(150, 34),
                                  backgroundColor: Color(hexColor('#003459')),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                child: Text(
                                  'SIGN IN',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontFamily: "Raleway",
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

                            // REDIRECT TO CREATE ACCOUNT PAGE
                            GestureDetector(
                              onTap: () {
                                RedirectCreateAccount(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Text(
                                  'New? Create Account',
                                  style: TextStyle(
                                      color: Color(hexColor('#003459')),
                                      fontSize: 17,
                                      fontFamily: "Raleway",
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 86),
                        child: Image.asset(
                          "images/parkbai_icon.png",
                          height: 100,
                          width: 100,
                        )),
                    Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 560),
                        child: Image.asset(
                          "images/WORDMARK1.png",
                          height: 200,
                          // width: 390,
                        )),
                  ],
                )
              ],
            )));
  }
}
