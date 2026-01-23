import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RideHistoryScreen extends StatefulWidget {
  static const String idScreen = "rideHistory";

  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  List<QueryDocumentSnapshot> _rideHistory = [];

  @override
  void initState() {
    super.initState();
    _getRideHistory();
  }

  Future<void> _getRideHistory() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference ridesRef = FirebaseFirestore.instance.collection('rides');

    // Query for rides where the user is the rider
    ridesRef.where("rider_id", isEqualTo: userId).snapshots().listen((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _rideHistory.addAll(querySnapshot.docs);
        });
      }
    });

    // Query for rides where the user is the driver
    ridesRef.where("driver_id", isEqualTo: userId).snapshots().listen((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.forEach((doc) {
          if (!_rideHistory.any((ride) => ride.id == doc.id)) {
            setState(() {
              _rideHistory.add(doc);
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique des courses"),
      ),
      body: ListView.builder(
        itemCount: _rideHistory.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text("Course du ${_rideHistory[index].get('created_at')}"),
              subtitle: Text("Status: ${_rideHistory[index].get('status')}"),
              trailing: Text("Tarif: \$${_rideHistory[index].get('fare')}"),
            ),
          );
        },
      ),
    );
  }
}
