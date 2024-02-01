import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class accountSetting extends StatefulWidget {
  const accountSetting({super.key});

  @override
  State<accountSetting> createState() => _accountSettingState();
}

//HEXCOLOR FOR COLORPALLETE
int hexColor(String color) {
  String newColor = '0xff' + color;
  newColor = newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}

final phonenumbertext = TextEditingController();
final addresstext = TextEditingController();
final oldPasswordtext = TextEditingController();
final newPasswordtext = TextEditingController();
String reUploadimageDLUrl = "";
String reUploadimageUrl = "";

class _accountSettingState extends State<accountSetting> {
  DatabaseReference? accountSettingRef;
  Stream? accountSettingStream;

  @override
  void initState() {
    super.initState();
    initializeAccountSettingStream();
  }

  void initializeAccountSettingStream() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      accountSettingRef = FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(user.uid)
          .child('ACCOUNT');

      accountSettingStream = accountSettingRef!.onValue;
    }
  }

  void updateAccountSetting() {
    User? user = FirebaseAuth.instance.currentUser;
    String userUID = user!.uid;

    print(newPasswordtext.text);

    if (newPasswordtext.text.isEmpty) {
      FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(userUID)
          .child('ACCOUNT')
          .update({
        'address': addresstext.text.toLowerCase(),
        'phonenumber': phonenumbertext.text,
      });
    } else {
      FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(userUID)
          .child('ACCOUNT')
          .update({
        'address': addresstext.text.toLowerCase(),
        'phonenumber': phonenumbertext.text,
        'password': newPasswordtext.text.toLowerCase()
      });
    }
  }

  //METHOD FOR UPLOADING IMAGE TO FIREBASE STORAGE
// ignore: non_constant_identifier_names
  void reUploadImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) {
      // User canceled image picker
      return;
    }
    List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];

    // Extract the file extension from the original file name
    String fileExtension = image.path.split('.').last;

    if (!allowedExtensions.contains(fileExtension)) {
      // Display an error message or handle the case where the selected file has an invalid extension
      print('Invalid file extension. Please select a valid image file.');
      return;
    }

    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    // Append the file extension to the new file name
    String fileType = 'image';

    Reference ref = FirebaseStorage.instance
        .ref()
        .child("DRIVER")
        .child('$imageName.$fileExtension');

    SettableMetadata metadata = SettableMetadata(
      contentType:
          'image/$fileExtension', // Set the content type based on the file extension
      customMetadata: {
        'fileType': fileType,
        'extension': fileExtension,
      }, // You can add more metadata as needed
    );

    await ref.putFile(File(image.path), metadata);

    await ref.getDownloadURL().then((value) {
      setState(() {
        reUploadimageUrl = value;
      });
    });
  }

  void reUploadImageforDL() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) {
      // User canceled image picker
      return;
    }

    List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];

    // Extract the file extension from the original file name
    String fileExtension = image.path.split('.').last;

    if (!allowedExtensions.contains(fileExtension)) {
      // Display an error message or handle the case where the selected file has an invalid extension
      print('Invalid file extension. Please select a valid image file.');
      return;
    }

    String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    // Append the file extension to the new file name
    String fileType = 'image';

    Reference ref = FirebaseStorage.instance
        .ref()
        .child("DRIVER")
        .child("DRIVER_LICENSE")
        .child('$imageName.$fileExtension');

    SettableMetadata metadata = SettableMetadata(
      contentType:
          'image/$fileExtension', // Set the content type based on the file extension
      customMetadata: {
        'fileType': fileType,
        'extension': fileExtension,
      }, // You can add more metadata as needed
    );

    await ref.putFile(File(image.path), metadata);

    await ref.getDownloadURL().then((value) {
      setState(() {
        reUploadimageDLUrl = value;
      });
    });
  }

  void reUploadImagesLink() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userUID = user!.uid;
    await FirebaseDatabase.instance
        .ref()
        .child('DRIVER')
        .child(userUID)
        .child('ACCOUNT')
        .update(
            {'imageUrl': reUploadimageUrl, 'imageDLUrl': reUploadimageDLUrl});
    print('URL sa driver ');
    print(reUploadimageUrl);
  }

  var currentUser = FirebaseAuth.instance.currentUser;

  changePassword({currentEmail, oldPassword, newPassword}) async {
    try {
      // Reauthenticate the user with their current email and password.
      var credentials = EmailAuthProvider.credential(
          email: currentEmail, password: oldPassword);
      await currentUser!.reauthenticateWithCredential(credentials);

      // Update the user's password to the new password.
      await currentUser!.updatePassword(newPassword);

      print("Password change successful");
      // You can provide user feedback here, such as a success message.
    } catch (error) {
      print("Error changing password: $error");
      // Handle the error. You can display an error message to the user.
    }
  }

  void clearInputIfBack() {
    phonenumbertext.clear();
    addresstext.clear();
    oldPasswordtext.clear();
    newPasswordtext.clear();
    reUploadimageDLUrl = " ";
    reUploadimageUrl = " ";
  }

  bool showOldpass = true;
  bool showNewpass = true;

  String errortextaddress = '';
  String errortextphone = '';
  String errortextemail = '';
  String errortextoldpass = '';
  String errortextnewpass = '';
  String passwordMatch = '';

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: accountSettingStream,
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            DataSnapshot dataValues = snapshot.data!.snapshot;
            // Check if the 'users' node exists in the database
            if (dataValues.value != null && dataValues.value is Map) {
              final Map<dynamic, dynamic> userData =
                  dataValues.value as Map<dynamic, dynamic>;
              // Retrieve data safely
              final String? imageurl = userData['imageUrl']?.toString();
              final String? imageDLurl = userData['imageDLUrl']?.toString();
              final String? fname = userData['firstname']?.toString();
              final String? mname = userData['middlename']?.toString();
              final String? lname = userData['lastname']?.toString();
              final String? email = userData['email']?.toString();
              final String? phonenumber = userData['phonenumber']?.toString();
              final String? address = userData['address']?.toString();
              final String? currentPassword = userData['password']?.toString();
              // final int? balance = userData['balance']?.toInt();

              return Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      clearInputIfBack();
                      Navigator.of(context).pop();
                    },
                  ),
                  centerTitle: true,
                  title: Text('ACCOUNT SETTING',
                      style: GoogleFonts.raleway(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                  backgroundColor: Color(hexColor('#003459')),
                ),
                body: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 13.0),
                          child: Container(
                            height: 1113,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFE2C946),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    reUploadImage();
                                  },
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: CircleAvatar(
                                          radius: 100.0,
                                          backgroundColor: Color(0xFFE2C946),
                                          child: reUploadimageUrl == " "
                                              ? CircleAvatar(
                                                  radius: 99.0,
                                                  backgroundImage: NetworkImage(
                                                      '${imageurl}'),
                                                  backgroundColor:
                                                      Color(0xFFE2C946),
                                                )
                                              : CircleAvatar(
                                                  radius: 95.0,
                                                  backgroundImage: NetworkImage(
                                                      reUploadimageUrl),
                                                  backgroundColor:
                                                      Color(0xFFE2C946),
                                                )),
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          'Fullname: ',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Text(
                                          '${fname} ${lname}, ${mname}',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE4F4FF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Address: ',
                                        style: GoogleFonts.raleway(
                                          fontSize: 17,
                                          color: Color(0xFFE2C946),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 250,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 0),
                                          child: TextField(
                                            controller: addresstext,
                                            autofocus: true,
                                            maxLength: 30,
                                            onChanged: (value) {
                                              setState(() {
                                                if (value.isEmpty) {
                                                  errortextaddress =
                                                      "Address is required.";
                                                } else if (value.isNotEmpty) {
                                                  errortextaddress = "";
                                                } else if (value.length < 8) {
                                                  errortextaddress =
                                                      "address should atleast 8 character";
                                                }
                                              });
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              counterText: "",
                                              errorText:
                                                  errortextaddress.isEmpty
                                                      ? null
                                                      : errortextaddress,
                                              hintText: '${address}',
                                              hintStyle: TextStyle(
                                                color: Color(0xFFE4F4FF),
                                                fontFamily: "Raleway",
                                                fontWeight: FontWeight.bold,
                                              ),
                                              labelStyle: TextStyle(
                                                color: Color(0xFFE2C946),
                                                fontFamily: "Raleway",
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            style: const TextStyle(
                                              color: Color(0xFFE4F4FF),
                                              fontFamily: "Raleway",
                                              fontWeight: FontWeight.bold,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                if (addresstext.text.isEmpty) {
                                                  addresstext.text =
                                                      address.toString();
                                                  print(addresstext.text);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Phone #: ',
                                        style: GoogleFonts.raleway(
                                          fontSize: 17,
                                          color: Color(0xFFE2C946),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 250,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 0),
                                          child: TextField(
                                            controller: phonenumbertext,
                                            autofocus: true,
                                            maxLength: 11,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                if (value.isEmpty) {
                                                  errortextphone =
                                                      "Phonenumber is required.";
                                                }
                                                // else if (value
                                                //     .contains(' ')) {
                                                //   errortextphone =
                                                //       "invalid input blank space detected.";
                                                // }
                                                else if (!value
                                                    .startsWith('09')) {
                                                  errortextphone =
                                                      "invalid phone number detected.";
                                                } else if (value.length < 3) {
                                                  errortextphone =
                                                      "Phonenumber should atleast 3 character";
                                                } else if (value.length < 11) {
                                                  errortextphone =
                                                      "phonenumber should 11 digits";
                                                } else if (value.isNotEmpty) {
                                                  errortextphone = "";
                                                }
                                              });
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              counterText: "",
                                              errorText: errortextphone.isEmpty
                                                  ? null
                                                  : errortextphone,
                                              hintText: '${phonenumber}',
                                              hintStyle: TextStyle(
                                                color: Color(0xFFE4F4FF),
                                                fontFamily: "Raleway",
                                                fontWeight: FontWeight.bold,
                                              ),
                                              labelStyle: TextStyle(
                                                color: Color(0xFFE2C946),
                                                fontFamily: "Raleway",
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            style: const TextStyle(
                                              color: Color(0xFFE4F4FF),
                                              fontFamily: "Raleway",
                                              fontWeight: FontWeight.bold,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                if (phonenumbertext
                                                    .text.isEmpty) {
                                                  phonenumbertext.text =
                                                      phonenumber.toString();
                                                  print(phonenumbertext.text);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'Email: ',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          '${email}',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE4F4FF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          'Old password: ',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      //TEXTFIELD FOR OLD PASSWORD
                                      SizedBox(
                                        width: 207,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 15),
                                          child: TextField(
                                            maxLength: 15,
                                            controller: oldPasswordtext,
                                            obscureText: showOldpass,
                                            autofocus: true,
                                            onChanged: (value) {
                                              setState(() {
                                                if (value.contains(' ')) {
                                                  errortextoldpass =
                                                      "invalid input blank space detected.";
                                                } else if (value.length < 8) {
                                                  errortextoldpass =
                                                      "password should atleast 8 characters";
                                                } else if (value.isEmpty) {
                                                  errortextoldpass =
                                                      "old password is required";
                                                } else if (value.isNotEmpty) {
                                                  errortextoldpass = "";
                                                }
                                              });
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              counterText: "",
                                              errorText:
                                                  errortextoldpass.isEmpty
                                                      ? null
                                                      : errortextoldpass,
                                              hintText: '',
                                              hintStyle: TextStyle(
                                                color: Color(0xFFE4F4FF),
                                                fontFamily: "Raleway",
                                                fontWeight: FontWeight.bold,
                                              ),
                                              suffixIcon: IconButton(
                                                icon: showOldpass
                                                    ? Icon(
                                                        Icons.visibility,
                                                        color:
                                                            Color(0xFFE4F4FF),
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .visibility_off_outlined,
                                                        color:
                                                            Color(0xFFE4F4FF),
                                                      ),
                                                onPressed: () {
                                                  setState(() {
                                                    showOldpass = !showOldpass;
                                                  });
                                                },
                                              ),
                                            ),
                                            style: const TextStyle(
                                              color: Color(0xFFE4F4FF),
                                              fontFamily: "Raleway",
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          'New password: ',
                                          style: GoogleFonts.raleway(
                                            fontSize: 17,
                                            color: Color(0xFFE2C946),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      //TEXTFIELD FOR NEW PASSWORD
                                      SizedBox(
                                        width: 200,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10),
                                          child: TextField(
                                            maxLength: 15,
                                            controller: newPasswordtext,
                                            obscureText: showNewpass,
                                            autofocus: true,
                                            onChanged: (value) {
                                              setState(() {
                                                if (value.contains(' ')) {
                                                  errortextnewpass =
                                                      "invalid input blank space detected.";
                                                } else if (value.length < 8) {
                                                  errortextnewpass =
                                                      "password should atleast 8 characters";
                                                } else if (value.isEmpty) {
                                                  errortextnewpass =
                                                      "new password is required";
                                                } else if (value.isNotEmpty) {
                                                  errortextnewpass = "";
                                                }
                                              });
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              counterText: "",
                                              errorText:
                                                  errortextnewpass.isEmpty
                                                      ? null
                                                      : errortextnewpass,
                                              hintText: 'new password?',
                                              hintStyle: TextStyle(
                                                color: Color(0xFFE4F4FF),
                                                fontSize: 15,
                                                fontFamily: "Raleway",
                                                fontWeight: FontWeight.bold,
                                              ),
                                              suffixIcon: IconButton(
                                                icon: showNewpass
                                                    ? Icon(
                                                        Icons.visibility,
                                                        color:
                                                            Color(0xFFE4F4FF),
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .visibility_off_outlined,
                                                        color:
                                                            Color(0xFFE4F4FF),
                                                      ),
                                                onPressed: () {
                                                  setState(() {
                                                    showNewpass = !showNewpass;
                                                  });
                                                },
                                              ),
                                            ),
                                            style: const TextStyle(
                                              color: Color(0xFFE4F4FF),
                                              fontFamily: "Raleway",
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Driver License: ',
                                        style: GoogleFonts.raleway(
                                          fontSize: 17,
                                          color: Color(0xFFE2C946),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 13),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 0, top: 10, bottom: 10),
                                        child: GestureDetector(
                                          onTap: () {
                                            reUploadImageforDL();
                                            print(reUploadimageDLUrl);
                                          },
                                          child: reUploadimageDLUrl == " "
                                              ? Container(
                                                  width: 300.0,
                                                  height: 200.0,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black,
                                                        offset: Offset(0, 3),
                                                        blurRadius: 5,
                                                        spreadRadius:
                                                            0, // Shadow expands
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          '${imageDLurl}'),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  width: 300.0,
                                                  height: 200.0,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black,
                                                        offset: Offset(0, 3),
                                                        blurRadius: 5,
                                                        spreadRadius:
                                                            0, // Shadow expands
                                                      ),
                                                    ],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          reUploadimageDLUrl),
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //BUTTON FOR SUBMIT CHANGE ACCOUNT SETTING
                                Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (addresstext.text.isEmpty) {
                                        Fluttertoast.showToast(
                                          msg: "please input your address.",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 5,
                                          backgroundColor:
                                              Color(hexColor('#003459')),
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                        addresstext.text = address.toString();
                                      } else if (phonenumbertext.text.isEmpty) {
                                        Fluttertoast.showToast(
                                          msg:
                                              "please input your phone number.",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 5,
                                          backgroundColor:
                                              Color(hexColor('#003459')),
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                        phonenumbertext.text =
                                            phonenumber.toString();
                                      } else if (oldPasswordtext.text.isEmpty) {
                                        Fluttertoast.showToast(
                                          msg:
                                              "please input your current password.",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 5,
                                          backgroundColor:
                                              Color(hexColor('#003459')),
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      } else if (currentPassword !=
                                          oldPasswordtext.text) {
                                        Fluttertoast.showToast(
                                          msg:
                                              "current password was incorrect.",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 5,
                                          backgroundColor:
                                              Color(hexColor('#003459')),
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                        print("old password not match");
                                      } else {
                                        // updateAccountSettingwithDialog(context);
                                        updateAccountSetting();
                                        print('link sa DL=');
                                        print(reUploadimageDLUrl);
                                        reUploadImagesLink();
                                        Fluttertoast.showToast(
                                          msg: "Account update successfully",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 5,
                                          backgroundColor:
                                              Color(hexColor('#003459')),
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                        Navigator.of(context).pop();
                                        print("success update");
                                      }
                                      await changePassword(
                                          currentEmail: email,
                                          oldPassword: oldPasswordtext.text,
                                          newPassword: newPasswordtext.text);
                                      oldPasswordtext.clear();
                                      newPasswordtext.clear();
                                    },
                                    style: ElevatedButton.styleFrom(
                                        fixedSize: const Size(150, 34),
                                        backgroundColor:
                                            Color(hexColor('#003459')),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        shadowColor: Colors.white),
                                    child: Row(
                                      children: [
                                        Icon(Icons.update_outlined),
                                        SizedBox(width: 8),
                                        Text(
                                          "UPDATE",
                                          style: GoogleFonts.raleway(
                                            fontSize: 15,
                                            color: Color(0xFFE4F4FF),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              // Handle the case where the 'users' node or expected data is missing
              return Text('User data not found');
            }
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
}
