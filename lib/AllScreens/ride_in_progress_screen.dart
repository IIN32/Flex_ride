import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_ride/AllScreens/rating_screen.dart';
import 'package:flex_ride/Models/ride_request.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideInProgressScreen extends StatefulWidget {
  final RideRequest rideRequest;

  const RideInProgressScreen({super.key, required this.rideRequest});

  @override
  State<RideInProgressScreen> createState() => _RideInProgressScreenState();
}

class _RideInProgressScreenState extends State<RideInProgressScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  StreamSubscription? rideStreamSubscription;
  LatLng? driverLocation;

  @override
  void initState() {
    super.initState();
    listenToRideUpdates();
  }

  void listenToRideUpdates() {
    DocumentReference rideRef = FirebaseFirestore.instance
        .collection('rides')
        .doc(widget.rideRequest.rideRequestId!);
    rideStreamSubscription = rideRef.snapshots().listen((doc) {
      if (doc.exists) {
        Map<String, dynamic> values = doc.data() as Map<String, dynamic>;
        if (values['driver_location'] != null) {
          setState(() {
            driverLocation = LatLng(values['driver_location']['latitude'],
                values['driver_location']['longitude']);
          });
        }
        if (values['status'] == 'completed') {
          rideStreamSubscription?.cancel();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RatingScreen(rideRequestId: widget.rideRequest.rideRequestId!),
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
      appBar: AppBar(
        title: const Text("Course en cours"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.rideRequest.pickup!,
              zoom: 14.4746,
            ),
            markers: {
              if (driverLocation != null)
                Marker(
                  markerId: const MarkerId('driver'),
                  position: driverLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure),
                )
            },
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                completeTrip();
              },
              child: const Text("Terminer la course"),
            ),
          )
        ],
      ),
    );
  }

  void completeTrip() {
    DocumentReference rideRef =
        FirebaseFirestore.instance.collection('rides').doc(widget.rideRequest.rideRequestId!);
    rideRef.update({"status": "completed"});
  }
}
