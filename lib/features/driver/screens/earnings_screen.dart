import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EarningsScreen extends StatefulWidget {
  static const String idScreen = "earnings";

  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  List<QueryDocumentSnapshot> _completedRides = [];
  double _totalEarnings = 0.0;

  @override
  void initState() {
    super.initState();
    _getCompletedRides();
  }

  Future<void> _getCompletedRides() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference ridesRef = FirebaseFirestore.instance.collection('rides');

    ridesRef
        .where("driver_id", isEqualTo: userId)
        .where("status", isEqualTo: "completed")
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        double totalEarnings = 0.0;
        for (var doc in querySnapshot.docs) {
          totalEarnings += doc.get('fare');
        }
        setState(() {
          _completedRides = querySnapshot.docs;
          _totalEarnings = totalEarnings;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gains"),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              "Total des gains: $_totalEarnings",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _completedRides.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text("Course de ${_completedRides[index].get('rider_name')}"),
                    subtitle: Text(
                        "De: ${_completedRides[index].get('pickup')}\nÀ: ${_completedRides[index].get('dropoff')}"),
                    trailing: Text("Gains: \$${_completedRides[index].get('fare')}"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
