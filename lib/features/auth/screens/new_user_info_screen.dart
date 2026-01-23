import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_ride/features/rider/screens/main_screen.dart';
import 'package:flex_ride/shared/widgets/progress_dialog.dart';
import 'package:flex_ride/shared/widgets/toast.dart';
import 'package:flex_ride/main.dart';
import 'package:flutter/material.dart';

class NewUserInfoScreen extends StatefulWidget {
  static const String idScreen = "newUserInfo";
  final String phone;

  const NewUserInfoScreen({super.key, required this.phone});

  @override
  State<NewUserInfoScreen> createState() => _NewUserInfoScreenState();
}

class _NewUserInfoScreenState extends State<NewUserInfoScreen> {
  final TextEditingController nameTextEditingController = TextEditingController();

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
                "Entrez votre nom",
                style: TextStyle(fontSize: 24.0, fontFamily: "Brand Bold"),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 1.0,
                    ),
                    TextField(
                      controller: nameTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Nom d'utilisateur",
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
                              "Enregistrer",
                              style: TextStyle(
                                  fontSize: 18.0, fontFamily: "Brand Bold"),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (nameTextEditingController.text.length < 3) {
                            displayToastMessage(
                                "Le nom doit comporter au moins 3 caractères.",
                                context);
                          } else {
                            registerNewUser(context);
                          }
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

  void registerNewUser(BuildContext context) {
    final User? firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const ProgressDialog(
              message: "Enregistrement en cours...",
            );
          });
      //user create
      //save user data into database
      Map<String, dynamic> userDataMap = {
        "name": nameTextEditingController.text.trim(),
        "phone": widget.phone.trim(),
      };

      usersRef.doc(firebaseUser.uid).set(userDataMap);
      displayToastMessage("Félicitations compte enregistré.", context);

      Navigator.pushNamedAndRemoveUntil(
          context, MainScreen.idScreen, (route) => false);
    } else {
      Navigator.pop(context);
      //error occured-display error msg
      displayToastMessage("Le compte utilisateur n'a pas été créé.", context);
    }
  }
}
