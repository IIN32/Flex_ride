import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_ride/features/rider/screens/main_screen.dart';
import 'package:flex_ride/features/auth/screens/new_user_info_screen.dart';
import 'package:flex_ride/shared/widgets/progress_dialog.dart';
import 'package:flex_ride/AllWidgets/toast.dart';
import 'package:flex_ride/main.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phone;

  const OtpScreen({super.key, required this.verificationId, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(
                height: 20.0,
              ),
              const Image(
                image: AssetImage("images/logo.png"),
                width: 390.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              const SizedBox(
                height: 1.0,
              ),
              const Text(
                "Vérification OTP",
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      controller: otpTextEditingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Code de vérification",
                        labelStyle: TextStyle(
                          fontSize: 14.0,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.white70,
                          fontSize: 10.0,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14.0),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.yellow,
                          backgroundColor: Colors.cyanAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.0),
                          ), // change text color of button
                        ),
                        child: const SizedBox(
                          height: 50.0,
                          child: Center(
                            child: Text(
                              "Vérifier",
                              style: TextStyle(
                                  fontSize: 18.0, fontFamily: "Brand Bold"),
                            ),
                          ),
                        ),
                        onPressed: () {
                          signInWithPhoneNumber();
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void signInWithPhoneNumber() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const ProgressDialog(
            message: "Vérification du code...",
          );
        });

    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otpTextEditingController.text,
      );

      final User? firebaseUser =
          (await _firebaseAuth.signInWithCredential(credential)).user;
      if (firebaseUser != null) {
        usersRef.doc(firebaseUser.uid).get().then((doc) {
          if (doc.exists) {
            Navigator.pushNamedAndRemoveUntil(
                context, MainScreen.idScreen, (route) => false);
            displayToastMessage("Authentification réussie.", context);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewUserInfoScreen(
                  phone: widget.phone,
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      Navigator.pop(context);
      displayToastMessage("Error: $e", context);
    }
  }
}
