import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_ride/features/rider/screens/waiting_screen.dart';
import 'package:flex_ride/Assistants/assistantMethods.dart';
import 'package:flex_ride/DataHandler/appData.dart';
import 'package:flex_ride/Models/directDetails.dart';
import 'package:flex_ride/models/vehicle_type.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class RidePreviewScreen extends StatefulWidget {
  final DirectionDetails directionDetails;

  const RidePreviewScreen({super.key, required this.directionDetails});

  @override
  State<RidePreviewScreen> createState() => _RidePreviewScreenState();
}

class _RidePreviewScreenState extends State<RidePreviewScreen> {
  VehicleType _selectedVehicle = VehicleType.Car;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aperçu de la course"),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  Provider.of<AppData>(context).pickUpLocation!.latitude!,
                  Provider.of<AppData>(context).pickUpLocation!.longitude!,
                ),
                zoom: 14.4746,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SegmentedButton<VehicleType>(
                  segments: const <ButtonSegment<VehicleType>>[
                    ButtonSegment<VehicleType>(
                        value: VehicleType.Car, label: Text('Car')),
                    ButtonSegment<VehicleType>(
                        value: VehicleType.Tricycle, label: Text('Tricycle')),
                    ButtonSegment<VehicleType>(
                        value: VehicleType.Motorcycle, label: Text('Motorcycle')),
                  ],
                  selected: <VehicleType>{_selectedVehicle},
                  onSelectionChanged: (Set<VehicleType> newSelection) {
                    setState(() {
                      _selectedVehicle = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  "Tarif de la course: ${AssistantMethods.calculateFares(widget.directionDetails, _selectedVehicle)}",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Brand-Bold"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    createRideRequest();
                  },
                  child: const Text("Demander une course"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void createRideRequest() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CollectionReference rideRequestRef = FirebaseFirestore.instance.collection('rides');
      String rideRequestId = rideRequestRef.doc().id;
      rideRequestRef.doc(rideRequestId).set({
        "rider_name": user.displayName,
        "rider_phone": user.phoneNumber,
        "pickup": {
          "latitude": Provider.of<AppData>(context, listen: false).pickUpLocation!.latitude,
          "longitude": Provider.of<AppData>(context, listen: false).pickUpLocation!.longitude,
        },
        "dropoff": {
          "latitude": Provider.of<AppData>(context, listen: false).dropOffLocation!.latitude,
          "longitude": Provider.of<AppData>(context, listen: false).dropOffLocation!.longitude,
        },
        "created_at": DateTime.now().toString(),
        "status": "pending",
        "fare": AssistantMethods.calculateFares(widget.directionDetails, _selectedVehicle),
        "ride_request_id": rideRequestId,
        "vehicle_type": _selectedVehicle.toString(),
      });

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => WaitingScreen(rideRequestId: rideRequestId)),
      );
    }
  }
}
