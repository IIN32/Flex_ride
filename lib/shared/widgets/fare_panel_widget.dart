import 'package:flex_ride/models/vehicle_type.dart';
import 'package:flex_ride/Assistants/assistantMethods.dart';
import 'package:flex_ride/Models/directDetails.dart';
import 'package:flutter/material.dart';

class FarePanelWidget extends StatelessWidget {
  final DirectionDetails directionDetails;
  final Function createRideRequest;
  final VehicleType vehicleType;

  const FarePanelWidget(
      {super.key, required this.directionDetails, required this.createRideRequest, required this.vehicleType});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 0.5,
            offset: Offset(0.7, 0.7),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tarif de la course: ${AssistantMethods.calculateFares(directionDetails, vehicleType)}",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Brand-Bold"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                createRideRequest();
              },
              child: const Text("Demander une course"),
            ),
          ],
        ),
      ),
    );
  }
}
