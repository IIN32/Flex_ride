import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_ride/AllWidgets/toast.dart';
import 'package:flutter/material.dart';

class EmergencyContactScreen extends StatefulWidget {
  static const String idScreen = "emergencyContact";

  const EmergencyContactScreen({super.key});

  @override
  State<EmergencyContactScreen> createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final TextEditingController _emergencyContactController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getEmergencyContact();
  }

  Future<void> _getEmergencyContact() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    userRef.snapshots().listen((doc) {
      if (doc.exists) {
        setState(() {
          _emergencyContactController.text = doc.get('emergency_contact');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact d'urgence"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _emergencyContactController,
              decoration: const InputDecoration(
                labelText: "Numéro de téléphone d'urgence",
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveEmergencyContact();
              },
              child: const Text("Enregistrer"),
            ),
          ],
        ),
      ),
    );
  }

  void _saveEmergencyContact() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    userRef.update({"emergency_contact": _emergencyContactController.text});
    displayToastMessage("Contact d'urgence enregistré.", context);
  }
}
