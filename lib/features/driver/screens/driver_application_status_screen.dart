import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverApplicationStatusScreen extends StatefulWidget {
  static const String idScreen = "driverApplicationStatus";

  const DriverApplicationStatusScreen({super.key});

  @override
  State<DriverApplicationStatusScreen> createState() =>
      _DriverApplicationStatusScreenState();
}

class _DriverApplicationStatusScreenState
    extends State<DriverApplicationStatusScreen> {
  String? _applicationStatus;

  @override
  void initState() {
    super.initState();
    _getApplicationStatus();
  }

  Future<void> _getApplicationStatus() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference driverApplicationRef =
        FirebaseFirestore.instance.collection('drivers').doc(userId);

    driverApplicationRef.snapshots().listen((doc) {
      if (doc.exists) {
        setState(() {
          _applicationStatus = doc.get('status');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statut de la demande"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Statut de votre demande:',
              style: TextStyle(fontSize: 20),
            ),
            if (_applicationStatus != null)
              Text(
                _applicationStatus!,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              )
            else
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
