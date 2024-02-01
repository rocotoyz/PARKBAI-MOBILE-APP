import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parkbai/loginpage.dart';
import 'package:parkbai/main.dart';
import 'dart:io';

// import 'package:parkbai/homepage.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({Key? key}) : super(key: key);

  @override
  State<CreateAccount> createState() => _MyAppState();
}

//HEXCOLOR FOR COLORPALLETE
int hexColor(String color) {
  String newColor = '0xff' + color;
  newColor = newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}

String imageDLUrl = " ";
String imageUrl = " ";
final firstname = TextEditingController();
final middlename = TextEditingController();
final lastname = TextEditingController();
final phonenumber = TextEditingController();
final address = TextEditingController();
final email = TextEditingController();
final password = TextEditingController();
final conpassword = TextEditingController();
final licensenumber = TextEditingController();

//REDIRECT TO MAIN PAGE
// ignore: non_constant_identifier_names
void RedirectMainpage(BuildContext context) {
  Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (_) => const MainPage()));
}

//REDIRECT TO LOGIN PAGE
// ignore: non_constant_identifier_names
void BacktoLoginPage(BuildContext context) {
  Navigator.push(
    context,
    GoingBottomRoute(nextPage: LoginPage()),
  );
  // Navigator.pushReplacement(
  //     context, MaterialPageRoute(builder: (_) => const LoginPage()));
}

//USER SIGN OUT ACCOUNT
void signOutcreateAccount() {
  FirebaseAuth.instance.signOut();
  username.clear();
  password.clear();
}

//CLEAR ALL INPUT IN TEXTFIELD AFTER SUBMIT
void clearInput() {
  imageUrl = " ";
  imageDLUrl = " ";
  firstname.clear();
  middlename.clear();
  lastname.clear();
  phonenumber.clear();
  address.clear();
  email.clear();
  password.clear();
  conpassword.clear();
  licensenumber.clear();
}

//SHOWS POP UP MESSAGE AFTER CREATE ACCOUNT
@override
void afterSubmit(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("Account successfully created."),
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

String errortextconpass1 = '';
//USER CREDENTIAL PUSH TO FIREBASE AFTER SIGN UP
Future signUp(BuildContext context) async {
  showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            color: Color(hexColor('#003459')),
            backgroundColor: Colors.white,
          ),
        );
      });

  //METHOD FOR CHECKING EMAIL IF ALREADY EXIST
  try {
    if (password.text == conpassword.text) {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text.toLowerCase().trim(),
          password: password.text.toLowerCase().trim());

      User? user = FirebaseAuth.instance.currentUser;
      String userUID = user!.uid;

      FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(userUID)
          .child('ACCOUNT')
          .set({
        'imageUrl': imageUrl,
        'imageDLUrl': imageDLUrl,
        'firstname': firstname.text.toLowerCase(),
        'middlename': middlename.text.toLowerCase(),
        'lastname': lastname.text.toLowerCase(),
        'address': address.text.toLowerCase(),
        'phonenumber': phonenumber.text,
        'license': licensenumber.text,
        'email': email.text.toLowerCase(),
        'password': password.text.toLowerCase(),
        'balance': 0,
        'status': "offline",
        'time_in': '--:--:--',
        'time_out': '--:--:--',
        'date_start': '--/--/--',
        'date_end': '--/--/--'
      });

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      afterSubmit(context);
      clearInput();
      // signOutcreateAccount();
      // ignore: use_build_context_synchronously
      RedirectMainpage(context);
    } else {
      errortextconpass1 = 'password do not match';
    }
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context);
    if (e.code == 'email-already-in-use') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Email already exists, please try another one."),
          duration: Duration(seconds: 5),
          backgroundColor: Color(hexColor('#003459')),
        ),
      );
    }
    print('Error checking email existence: $e');
    return false;
  }
}

class GoingBottomRoute extends PageRouteBuilder {
  final Widget nextPage;

  GoingBottomRoute({required this.nextPage})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => nextPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, -1.0); // Slide from top to bottom
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

class _MyAppState extends State<CreateAccount> {
  bool showpass = true;
  bool showconpass = true;

  String errortextfname = '';
  String errortextlname = '';
  String errortextmname = '';
  String errortextaddress = '';
  String errortextphone = '';
  String errortextemail = '';
  String errortextpass = '';
  String errortextconpass = '';
  String errortextdriver = '';

  //METHOD FOR UPLOADING IMAGE TO FIREBASE STORAGE
// ignore: non_constant_identifier_names

  void UploadImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return; // User canceled image selection

    // Check if the selected file has a specific extension (e.g., jpg or png)
    List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];
    String fileExtension = image.path.split('.').last.toLowerCase();

    if (!allowedExtensions.contains(fileExtension)) {
      // Display an error message or handle the case where the selected file has an invalid extension
      print('Invalid file extension. Please select a valid image file.');
      return;
    }

    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    String fileType = 'image';

    Reference ref = FirebaseStorage.instance
        .ref()
        .child("DRIVER")
        .child('$imageName.$fileExtension');

    // Specify custom metadata with dynamically determined file type
    SettableMetadata metadata = SettableMetadata(
      contentType:
          'image/$fileExtension', // Set the content type based on the file extension
      customMetadata: {
        'fileType': fileType,
        'extension': fileExtension
      }, // You can add more metadata as needed
    );

    // Upload the file with custom metadata
    await ref.putFile(File(image.path), metadata);

    // Get the download URL
    await ref.getDownloadURL().then((value) {
      setState(() {
        imageUrl = value;
      });
    });
  }

  void UploadImageforDL() async {
    final imageDL = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (imageDL == null) return; // User canceled image selection

    // Check if the selected file has a specific extension (e.g., jpg or png)
    List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];
    String fileExtension = imageDL.path.split('.').last.toLowerCase();

    if (!allowedExtensions.contains(fileExtension)) {
      // Display an error message or handle the case where the selected file has an invalid extension
      print('Invalid file extension. Please select a valid image file.');
      return;
    }

    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    String fileType = 'image';

    Reference ref = FirebaseStorage.instance
        .ref()
        .child("DRIVER")
        .child('$imageName.$fileExtension');

    // Specify custom metadata with dynamically determined file type
    SettableMetadata metadata = SettableMetadata(
      contentType:
          'image/$fileExtension', // Set the content type based on the file extension
      customMetadata: {
        'fileType': fileType,
        'extension': fileExtension,
      }, // You can add more metadata as needed
    );

    // Upload the file with custom metadata
    await ref.putFile(File(imageDL.path), metadata);

    // Get the download URL
    await ref.getDownloadURL().then((value) {
      setState(() {
        imageDLUrl = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(hexColor('#003459')),
          appBar: AppBar(
              leading: BackButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              centerTitle: true,
              title: const Text(
                'CREATE ACCOUNT',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Raleway",
                    fontWeight: FontWeight.bold),
              ),
              backgroundColor: Color(hexColor('#003459'))),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 10),
                  width: MediaQuery.of(context).size.width,
                  height: 1513,
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
                      padding: const EdgeInsets.only(top: 14),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              UploadImage();
                            },
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 0.5),
                                  width: 375,
                                  height: 170,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    color: Color(hexColor('#003459')),
                                  ),
                                  child: Center(
                                    child: imageUrl == " "
                                        ? const Icon(
                                            Icons.add,
                                            size: 80,
                                            color: Colors.white,
                                          )
                                        : Image.network(imageUrl),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 8),
                                  child: Text(
                                    'Add your Photo',
                                    style: TextStyle(
                                      color: Color(hexColor('#003459')),
                                      fontSize: 15,
                                      fontFamily: "Raleway",
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              UploadImageforDL();
                            },
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 0.5),
                                  width: 375,
                                  height: 170,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(15)),
                                    color: Color(hexColor('#003459')),
                                  ),
                                  child: Center(
                                    child: imageDLUrl == " "
                                        ? const Icon(
                                            Icons.add,
                                            size: 80,
                                            color: Colors.white,
                                          )
                                        : Image.network(imageDLUrl),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Add your Driver License',
                                    style: TextStyle(
                                      color: Color(hexColor('#003459')),
                                      fontSize: 15,
                                      fontFamily: "Raleway",
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          //TEXTFIELD FOR FIRST NAME
                          SizedBox(
                            width: 370,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextField(
                                maxLength: 15,
                                controller: firstname,
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isEmpty) {
                                      errortextfname = "Firstname is required.";
                                    } else if (value.length < 3) {
                                      errortextfname =
                                          "firstname should atleast 3 character";
                                    } else if (value.isNotEmpty) {
                                      errortextfname = "";
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  counterText: "",
                                  errorText: errortextfname.isEmpty
                                      ? null
                                      : errortextfname,
                                  prefixIcon: Icon(Icons.person_outlined,
                                      color: Color(hexColor('#003459'))),
                                  isDense: true,
                                  labelText: 'Firstname',
                                  hintText: 'Firstname',
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
                          ),
                          //TEXTFIELD FOR MIDDLE NAME
                          SizedBox(
                            width: 370,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextField(
                                maxLength: 15,
                                controller: middlename,
                                onChanged: (value) {
                                  setState(() {
                                    if (value.contains(' ')) {
                                      errortextmname =
                                          "invalid input blank space detected.";
                                    } else if (value.isEmpty) {
                                      errortextmname =
                                          "Middlename is required.";
                                    } else if (value.length < 3) {
                                      errortextmname =
                                          "middlename should atleast 3 character";
                                    } else if (value.isNotEmpty) {
                                      errortextmname = "";
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  counterText: "",
                                  errorText: errortextmname.isEmpty
                                      ? null
                                      : errortextmname,
                                  prefixIcon: Icon(Icons.person_outlined,
                                      color: Color(hexColor('#003459'))),
                                  isDense: true,
                                  labelText: 'Middlename',
                                  hintText: 'Middlename',
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
                          ),
                          //TEXTFIELD FOR LAST NAME
                          SizedBox(
                            width: 370,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextField(
                                maxLength: 15,
                                controller: lastname,
                                onChanged: (value) {
                                  setState(() {
                                    if (value.contains(' ')) {
                                      errortextlname =
                                          "invalid input blank space detected.";
                                    } else if (value.isEmpty) {
                                      errortextlname = "Lastname is required.";
                                    } else if (value.length < 3) {
                                      errortextlname =
                                          "lastname should atleast 3 character";
                                    } else if (value.isNotEmpty) {
                                      errortextlname = "";
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  counterText: "",
                                  errorText: errortextlname.isEmpty
                                      ? null
                                      : errortextlname,
                                  prefixIcon: Icon(Icons.person_outlined,
                                      color: Color(hexColor('#003459'))),
                                  isDense: true,
                                  labelText: 'Lastname',
                                  hintText: 'Lastname',
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
                          ),
                          //TEXTFIELD FOR ADDRESS
                          SizedBox(
                            width: 370,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextField(
                                maxLength: 30,
                                controller: address,
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isEmpty) {
                                      errortextaddress = "Address is required.";
                                    } else if (value.length < 8) {
                                      errortextaddress =
                                          "address should atleast 8 character";
                                    } else if (value.isNotEmpty) {
                                      errortextaddress = "";
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  counterText: "",
                                  errorText: errortextaddress.isEmpty
                                      ? null
                                      : errortextaddress,
                                  prefixIcon: Icon(Icons.location_city_outlined,
                                      color: Color(hexColor('#003459'))),
                                  isDense: true,
                                  labelText: 'Address',
                                  hintText:
                                      'Street., zipcode, Barangay, City, Province',
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
                          ),
                          //TEXTFIELD FOR PHONENUMBER
                          SizedBox(
                            width: 370,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextField(
                                controller: phonenumber,
                                maxLength: 11,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    if (value.contains(' ')) {
                                      errortextphone =
                                          "invalid input blank space detected.";
                                    } else if (!value.startsWith('09')) {
                                      errortextphone =
                                          "invalid phone number detected.";
                                    } else if (value.length < 3) {
                                      errortextphone =
                                          "middlename should atleast 3 character";
                                    } else if (value.isEmpty) {
                                      errortextphone =
                                          "Phonenumber is required.";
                                    } else if (value.length < 11) {
                                      errortextphone =
                                          "phonenumber should 11 digits";
                                    } else if (value.isNotEmpty) {
                                      errortextphone = "";
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  counterText: "",
                                  errorText: errortextphone.isEmpty
                                      ? null
                                      : errortextphone,
                                  prefixIcon: Icon(Icons.phone_android_outlined,
                                      color: Color(hexColor('#003459'))),
                                  isDense: true,
                                  labelText: 'Phone number',
                                  hintText: '09XXXXXXXX',
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
                          ),
                          SizedBox(
                            width: 370,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextField(
                                controller: licensenumber,
                                maxLength: 16,
                                onChanged: (value) {
                                  // Validation logic for driver's license
                                  setState(() {
                                    // Assuming alphanumeric includes letters (a-z, A-Z) and numbers (0-9)
                                    RegExp alphanumeric =
                                        RegExp(r'^[a-zA-Z0-9]+$');

                                    if (value.isEmpty) {
                                      // Handle empty input
                                      errortextdriver =
                                          "Driver's license is required.";
                                    } else if (value.length != 16) {
                                      // Check length
                                      errortextdriver =
                                          "Driver's license should be 16 characters.";
                                    } else if (!alphanumeric.hasMatch(value)) {
                                      // Check alphanumeric
                                      errortextdriver =
                                          "Invalid characters detected.";
                                    } else {
                                      // No errors
                                      errortextdriver = "";
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  counterText: "",
                                  errorText: errortextdriver.isEmpty
                                      ? null
                                      : errortextdriver,
                                  prefixIcon: Icon(Icons.drive_eta_outlined,
                                      color: Colors.blue),
                                  isDense: true,
                                  labelText: 'Driver\'s License',
                                  hintText: 'Enter 16 characters',
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Raleway",
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          //TEXTFIELD FOR EMAIL
                          SizedBox(
                            width: 370,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextField(
                                controller: email,
                                onChanged: (value) {
                                  setState(
                                    () {
                                      if (value.contains(' ')) {
                                        errortextemail =
                                            "invalid input blank space detected.";
                                      } else if (value.isEmpty) {
                                        errortextemail = "Email is required.";
                                      } else if (value.length < 10) {
                                        errortextemail =
                                            "email should atleast 10 character";
                                      } else if (!RegExp(
                                              r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,}$')
                                          .hasMatch(value)) {
                                        errortextemail =
                                            "Incorrect email detected";
                                      } else if (value.isNotEmpty) {
                                        errortextemail = "";
                                      }
                                    },
                                  );
                                },
                                decoration: InputDecoration(
                                  counterText: "",
                                  errorText: errortextemail.isEmpty
                                      ? null
                                      : errortextemail,
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
                          ),
                          //TEXTFIELD FOR PASSWORD
                          SizedBox(
                            width: 370,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextField(
                                maxLength: 15,
                                controller: password,
                                obscureText: showpass,
                                onChanged: (value) {
                                  setState(() {
                                    if (value.contains(' ')) {
                                      errortextpass =
                                          "invalid input blank space detected.";
                                    } else if (value.isEmpty) {
                                      errortextpass = "password is required.";
                                    } else if (value.length < 8) {
                                      errortextpass =
                                          "password should atleast 8 characters";
                                    } else if (value.isNotEmpty) {
                                      errortextpass = "";
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  counterText: "",
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
                          ),
                          //TEXTFIELD FOR CONFIRM PASSWORD
                          SizedBox(
                            width: 370,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: TextField(
                                maxLength: 15,
                                controller: conpassword,
                                obscureText: showconpass,
                                onChanged: (value) {
                                  setState(() {
                                    if (value.contains(' ')) {
                                      errortextconpass =
                                          "invalid input blank space detected.";
                                    } else if (value.isEmpty) {
                                      errortextconpass =
                                          "confirm password is required.";
                                      // ignore: unrelated_type_equality_checks
                                    } else if (value.length < 8) {
                                      errortextconpass =
                                          "confirm password should atleast 8 characters";
                                    } else if (value != password.text) {
                                      errortextconpass =
                                          "password doesn't match!";
                                    } else if (value.isNotEmpty) {
                                      errortextconpass = "";
                                    }
                                  });
                                },
                                decoration: InputDecoration(
                                  counterText: "",
                                  errorText: errortextconpass.isEmpty
                                      ? null
                                      : errortextconpass,
                                  prefixIcon: Icon(Icons.password_outlined,
                                      color: Color(hexColor('#003459'))),
                                  suffixIcon: IconButton(
                                    icon: showconpass
                                        ? Icon(
                                            Icons.visibility,
                                            color: Color(hexColor('#003459')),
                                          )
                                        : const Icon(
                                            Icons.visibility_off_outlined,
                                            color: Colors.purple,
                                          ),
                                    onPressed: () {
                                      setState(() {
                                        showconpass = !showconpass;
                                      });
                                    },
                                  ),
                                  isDense: true,
                                  labelText: 'Confirm password',
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
                          ),

                          //BUTTON FOR SUBMIT CREATE ACCOUNT
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  if (password.text != conpassword.text) {
                                    errortextconpass1 =
                                        "password doesn't match!";
                                  } else {
                                    setState(() {
                                      signUp(context);
                                    });
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                fixedSize: const Size(150, 34),
                                backgroundColor: Color(hexColor('#003459')),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                              ),
                              child: const Text(
                                'SUBMIT',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontFamily: "Raleway",
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              clearInput();
                              BacktoLoginPage(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text(
                                'Already have an account? Sign in',
                                style: TextStyle(
                                    color: Color(hexColor('#003459')),
                                    fontSize: 17,
                                    fontFamily: "Raleway",
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ));
  }
}
