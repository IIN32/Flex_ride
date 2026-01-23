import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flex_ride/shared/widgets/progress_dialog.dart';
import 'package:flex_ride/AllWidgets/toast.dart';
import 'package:flutter/material.dart';

class DriverApplicationScreen extends StatefulWidget {
  static const String idScreen = "driverApplication";

  const DriverApplicationScreen({super.key});

  @override
  State<DriverApplicationScreen> createState() =>
      _DriverApplicationScreenState();
}

class _DriverApplicationScreenState extends State<DriverApplicationScreen> {
  final TextEditingController nameTextEditingController = TextEditingController();
  final TextEditingController carModelTextEditingController =
      TextEditingController();
  final TextEditingController carNumberTextEditingController =
      TextEditingController();
  File? _document;

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
                "Devenez chauffeur",
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
                      height: 1.0,
                    ),
                    TextField(
                      controller: carModelTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Modèle de voiture",
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
                      height: 1.0,
                    ),
                    TextField(
                      controller: carNumberTextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Numéro de voiture",
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
                      onPressed: _pickDocument,
                      child: const Text("Sélectionner un document"),
                    ),
                    if (_document != null)
                      Text("Document sélectionné: ${_document!.path}"),
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
                              "Soumettre la demande",
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
                          } else if (carModelTextEditingController.text.isEmpty) {
                            displayToastMessage(
                                "Le modèle de voiture est requis.", context);
                          } else if (carNumberTextEditingController.text.isEmpty) {
                            displayToastMessage(
                                "Le numéro de voiture est requis.", context);
                          } else if (_document == null) {
                            displayToastMessage(
                                "Veuillez sélectionner un document.", context);
                          } else {
                            saveDriverApplication(context);
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

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _document = File(result.files.single.path!);
      });
    } else {
      // User canceled the picker
    }
  }

  void saveDriverApplication(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const ProgressDialog(
            message: "Enregistrement de la demande...",
          );
        });

    String userId = FirebaseAuth.instance.currentUser!.uid;
    String? documentUrl;

    if (_document != null) {
      Reference storageReference =
          FirebaseStorage.instance.ref().child('documents/$userId');
      UploadTask uploadTask = storageReference.putFile(_document!);
      await uploadTask.whenComplete(() async {
        documentUrl = await storageReference.getDownloadURL();
      });
    }

    Map<String, dynamic> driverApplicationMap = {
      "name": nameTextEditingController.text.trim(),
      "car_model": carModelTextEditingController.text.trim(),
      "car_number": carNumberTextEditingController.text.trim(),
      "document_url": documentUrl,
      "status": "pending",
    };

    FirebaseFirestore.instance.collection('drivers').doc(userId).set(driverApplicationMap);

    Navigator.pop(context);
    displayToastMessage("Votre demande a été soumise.", context);
  }
}
