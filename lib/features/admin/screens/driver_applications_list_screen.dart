import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DriverApplicationsListScreen extends StatefulWidget {
  const DriverApplicationsListScreen({super.key});

  @override
  State<DriverApplicationsListScreen> createState() =>
      _DriverApplicationsListScreenState();
}

class _DriverApplicationsListScreenState
    extends State<DriverApplicationsListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Demandes des chauffeurs"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('drivers')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(snapshot.data!.docs[index].get('name')),
                    subtitle: Text(
                        "Modèle de voiture: ${snapshot.data!.docs[index].get('car_model')}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            approveDriver(
                                snapshot.data!.docs[index].id);
                          },
                          child: const Text("Approuver"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            rejectDriver(snapshot.data!.docs[index].id);
                          },
                          child: const Text("Rejeter"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void approveDriver(String driverId) {
    FirebaseFirestore.instance
        .collection('drivers')
        .doc(driverId)
        .update({'status': 'approved'});
  }

  void rejectDriver(String driverId) {
    FirebaseFirestore.instance
        .collection('drivers')
        .doc(driverId)
        .update({'status': 'rejected'});
  }
}
