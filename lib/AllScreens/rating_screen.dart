import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_ride/shared/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingScreen extends StatefulWidget {
  final String rideRequestId;

  const RatingScreen({super.key, required this.rideRequestId});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Évaluez votre course"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Évaluez votre chauffeur',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                submitRating();
              },
              child: const Text("Soumettre"),
            )
          ],
        ),
      ),
    );
  }

  void submitRating() {
    DocumentReference rideRef =
        FirebaseFirestore.instance.collection('rides').doc(widget.rideRequestId);
    rideRef.update({"rating": _rating});
    displayToastMessage("Merci d'avoir évalué votre course.", context);
    Navigator.pop(context);
  }
}
