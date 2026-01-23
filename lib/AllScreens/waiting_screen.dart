import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_ride/AllScreens/ride_in_progress_screen.dart';
import 'package:flex_ride/Models/ride_request.dart';
import 'package:flutter/material.dart';

class WaitingScreen extends StatefulWidget {
  final String rideRequestId;

  const WaitingScreen({super.key, required this.rideRequestId});

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  StreamSubscription? rideStreamSubscription;

  @override
  void initState() {
    super.initState();
    listenToRideUpdates();
  }

  void listenToRideUpdates() {
    DocumentReference rideRef =
        FirebaseFirestore.instance.collection('rides').doc(widget.rideRequestId);
    rideStreamSubscription = rideRef.snapshots().listen((doc) {
      if (doc.exists) {
        Map<String, dynamic> values = doc.data() as Map<String, dynamic>;
        if (values['status'] == 'accepted') {
          rideStreamSubscription?.cancel();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RideInProgressScreen(
                rideRequest: RideRequest.fromMap(values),
              ),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    rideStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Colors.white.withOpacity(0.8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              'Recherche de chauffeur...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
