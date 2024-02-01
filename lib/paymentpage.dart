import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:parkbai/homepage.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

//HEXCOLOR FOR COLORPALLETE
int hexColor(String color) {
  String newColor = '0xff' + color;
  newColor = newColor.replaceAll('#', '');
  int finalColor = int.parse(newColor);
  return finalColor;
}

void successPaymentDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Set the border radius
        ),
        contentPadding: EdgeInsets.zero, // Remove default padding
        content: Container(
          decoration: BoxDecoration(
            color: Color(hexColor('#003459')), // Background color
            borderRadius:
                BorderRadius.circular(10), // Optional: Add rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0, 3),
                blurRadius: 1,
                spreadRadius: 0, // Shadow expands
              ),
            ],
          ), // Set the background color
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(2.5),
                child: Icon(
                  Icons.check_circle_outline_outlined,
                  size: 70,
                  color: Color(0xFFE2C946),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(2.5),
                child: Text(
                  'Payment successful!',
                  style: GoogleFonts.raleway(
                    fontSize: 20,
                    color: Color(0xFFE4F4FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context, goingLeftPageRoute(nextPage: HomePage()));
                  },
                  child: Text(
                    'Done',
                    style: GoogleFonts.raleway(
                      fontSize: 18,
                      color: Color(0xFFE2C946),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PaymentPageState extends State<PaymentPage> {
  List<TextEditingController> amountControllers = [TextEditingController()];
  DatabaseReference? Balanceref;
  DatabaseReference? getBalanceref;
  DatabaseReference? getGeneralBalanceref;
  DatabaseReference? paymentHistoryref;
  DatabaseReference? driverToAdminref;
  DatabaseReference? drivetoAdminBalanceref;
  DatabaseReference? userPushGeneralBalance;
  Stream? getDriverBalanceRef;
  Stream? paymentGeneralBalanceStream;

  @override
  void initState() {
    super.initState();
  }

  void updateBalance() async {
  
    final User? drBalance = FirebaseAuth.instance.currentUser;
    if (drBalance != null) {
      getBalanceref = FirebaseDatabase.instance
          .ref()
          .child('DRIVER')
          .child(drBalance.uid)
          .child('ACCOUNT');

      DatabaseEvent event = await getBalanceref!.once();

      // Check if the 'balance' key exists in the snapshot and if it is not null
      if (event.snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic>? data =
            event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null && data['balance'] != null) {
          String fname = data['firstname'].toString();
          String mname = data['middlename'].toString();
          String lname = data['lastname'].toString();

          double balance = double.parse(data['balance'].toString());
          print('Current Balance: $balance');
          final User? driverBalance = FirebaseAuth.instance.currentUser;
          if (driverBalance != null) {
            Balanceref = FirebaseDatabase.instance
                .ref()
                .child('DRIVER')
                .child(driverBalance.uid)
                .child('ACCOUNT');
            List<double> amounts = [];
            for (int i = 0; i < amountControllers.length; i++) {
              double amount =
                  double.tryParse(amountControllers[i].text.toString()) ?? 0.0;
              double amountAsDouble = amount.toDouble();
              amounts.add(amountAsDouble);
            }
            double amountCashIn =
                amounts.fold(0, (previous, current) => previous + current);
            Map<String, dynamic> updateDRBalance = {
              'balance': amountCashIn + balance,
            };
            Balanceref?.update(updateDRBalance);

            DateTime now = DateTime.now();
            // ignore: unused_element
            final formattedDate =
                DateFormat('MMMM d, y (EEEE) HH:mm:ss').format(now);

            DateTime now2 = DateTime.now();
            String formattedDate2 = DateFormat('dd/MM/yyyy').format(now2);

            DateTime now3 = DateTime.now();
            String formattedDate3 = DateFormat('HH:mm:ss').format(now3);

            int generateRandomNumber() {
              Random random = Random();
              int min = 100000000; // Smallest 9-digit number
              int max = 999999999; // Largest 9-digit number
              return min + random.nextInt(max - min);
            }

            int randomNum = generateRandomNumber();
            print(randomNum);

            //MO PUSH UG MGA DATA SA CASH IN SA PAYMENT HISTORY
            final User? driverPaymentHistory =
                FirebaseAuth.instance.currentUser;
            if (driverPaymentHistory != null) {
              paymentHistoryref = FirebaseDatabase.instance
                  .ref()
                  .child('DRIVER')
                  .child(driverPaymentHistory.uid)
                  .child('PAYMENT_HISTORY');

              Map<dynamic, dynamic> pushPaymentHistory = {
                'date': formattedDate.toString(),
                'transaction_details': 'Cash-in',
                'amount': amountCashIn,
                'MOP': 'through PayPal',
                'ref_number': randomNum
              };
              paymentHistoryref?.push().set(pushPaymentHistory);
            }
            final User? DRpaymentToAdmin = FirebaseAuth.instance.currentUser;
            if (DRpaymentToAdmin != null) {
              driverToAdminref = FirebaseDatabase.instance
                  .ref()
                  .child('ADMIN')
                  .child('TRANSACTIONS')
                  .child('DRIVER');

              Map<dynamic, dynamic> pushToAdmin = {
                'amount': amountCashIn,
                'date': formattedDate2.toString(),
                'fullname': '${lname}, ${fname} ${mname}',
                'ref_number': randomNum,
                'type': 'cash-in',
                'UID': DRpaymentToAdmin.uid,
                'time': formattedDate3
              };
              driverToAdminref?.push().set(pushToAdmin);           
            }
            final User? curUser = FirebaseAuth.instance.currentUser;
            if(curUser != null){
              DatabaseReference generalBalanceRef = FirebaseDatabase.instance
                  .ref()
                  .child('ADMIN')
                  .child('general_balance');

              // Fetch the current general balance
              DatabaseEvent generalBalanceEvent =
                  await generalBalanceRef.once();
              DataSnapshot generalBalanceSnapshot =
                  generalBalanceEvent.snapshot;

              if (generalBalanceSnapshot.value != null) {
                double currentGeneralBalance =
                    double.parse(generalBalanceSnapshot.value.toString());

                // Set the updated value inside general_balance directly
                generalBalanceRef.set(amountCashIn + currentGeneralBalance);
              }
            }
          }
          successPaymentDialog(context);
          print(amountControllers);

          print('UPDATE NA ANG BALANCE');
        } else {
          print('Balance not found');
        }
      } else {
        print('Invalid data structure');
      }
    }
  }

  // Future<void> updateBalance() async {
  //   final User? driverBalance = FirebaseAuth.instance.currentUser;
  //   if (driverBalance != null) {
  //     Balanceref = FirebaseDatabase.instance
  //         .ref()
  //         .child('DRIVER')
  //         .child(driverBalance.uid)
  //         .child('ACCOUNT');
  //     List<double> amounts = [];
  //     for (int i = 0; i < amountControllers.length; i++) {
  //       double amount =
  //           double.tryParse(amountControllers[i].text.toString()) ?? 0.0;
  //       double amountAsDouble = amount.toDouble();
  //       amounts.add(amountAsDouble);
  //     }
  //     double amountCashIn =
  //         amounts.fold(0, (previous, current) => previous + current);
  //     Map<String, dynamic> updateDRBalance = {
  //       'balance': amountCashIn,
  //     };
  //     Balanceref?.update(updateDRBalance);
  //   }
  //   print(amountControllers);
  //   print('UPDATE NA ANG BALANCE');
  // }

// Function to display SnackBar
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.raleway(
            fontSize: 15, // Adjusted font size
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Color(0xFFE4F4FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            topRight: Radius.circular(8.0),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text('PAYMENT METHOD',
            style: GoogleFonts.raleway(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Color(hexColor('#003459')),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 250,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 19.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Enter your amount: ',
                style: GoogleFonts.raleway(
                  fontSize: 15,
                  color: Color(0xFFE4F4FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Display the TextFields for dynamic amount entry
          for (int i = 0; i < amountControllers.length; i++)
            Padding(
              padding: const EdgeInsets.only(
                  left: 13.0, right: 13, top: 5, bottom: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE4F4FF),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(0, 3),
                      blurRadius: 5,
                      spreadRadius: 0, // Shadow expands
                    ),
                  ],
                ),
                child: TextField(
                    maxLength: 5,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: amountControllers[i],
                    style: const TextStyle(
                      backgroundColor: const Color(0xFFE4F4FF),
                      color: const Color(0xFF003459),
                      fontSize: 18,
                      fontFamily: "Raleway",
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFFE4F4FF),
                        prefixIcon: Icon(Icons.php_outlined,
                            size: 40, color: const Color(0xFF003459)),
                        hintText: '00.00',
                        hintStyle: TextStyle(
                          fontSize: 18,
                          color: const Color(0xFF003459),
                          fontFamily: "Raleway",
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Color(0xFFE4F4FF))))),
              ),
            ),

          // Button to make payment
          TextButton(
            onPressed: () async {
              if (amountControllers
                  .any((controller) => controller.text.isEmpty)) {
                showSnackBar(
                    context, "please input your desire amount to proceed");
              } else {
                // Construct the transactions list based on entered amounts
                List<Map<String, dynamic>> transactions = [];
                for (int i = 0; i < amountControllers.length; i++) {
                  double amount =
                      double.tryParse(amountControllers[i].text) ?? 0.0;
                  transactions.add({
                    "amount": {
                      "total": amount.toString(),
                      "currency": "PHP",
                    },
                    "description": "Payment ${i + 1}",
                  });
                }
                // Navigate to the payment screen with the constructed transactions
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => UsePaypal(
                      sandboxMode: true,
                      clientId:
                          "AU0LZ2xqwr2EuC0Vplx4ZTkIk5yqqelI95UhkiCC7lNgGvovHjpb3vm6hP71mkYyIHnUGbvJu58Ni3eQ",
                      secretKey:
                          "EG_oJo6FunhEHxTA6a16VP2Z19fzmaB_865zpdKbGvL4Dz3NojPleFmw-xfXNkiebvLwyDPT8Nc2Fvjm",
                      returnURL: "https://samplesite.com/return",
                      cancelURL: "https://samplesite.com/cancel",
                      transactions: transactions,
                      note: "Contact us for any questions on your payment.",
                      onSuccess: (Map params) async {
                        print("onSuccess: $params");
                        // CALLING THIS FUNCTION PARA MO UPDATE ANG BALANCE
                        updateBalance();
                      },
                      onError: (error) {
                        print("onError: $error");
                      },
                      onCancel: (params) {
                        print('cancelled: $params');
                      },
                    ),
                  ),
                );
              }
            },
            child: Align(
              alignment: Alignment.center,
              child: Row(
                children: [
                  SizedBox(width: 140),
                  Text(
                    'PROCEED',
                    style: GoogleFonts.raleway(
                      fontSize: 17,
                      color: Color(0xFFE4F4FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_right_alt_outlined,
                    color: Color(0xFFE4F4FF),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
