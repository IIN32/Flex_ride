import 'package:flex_ride/Models/ride_request.dart';
import 'package:flutter/material.dart';

class TripDetailsWidget extends StatelessWidget {
  final RideRequest rideRequest;

  const TripDetailsWidget({super.key, required this.rideRequest});

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
              "Passager: ${rideRequest.riderName}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("De: ${rideRequest.pickup}"),
            const SizedBox(height: 10),
            Text("À: ${rideRequest.dropoff}"),
          ],
        ),
      ),
    );
  }
}
