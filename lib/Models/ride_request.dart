import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideRequest {
  String? riderName;
  String? riderPhone;
  LatLng? pickup;
  LatLng? dropoff;
  String? rideRequestId;

  RideRequest({
    this.riderName,
    this.riderPhone,
    this.pickup,
    this.dropoff,
    this.rideRequestId,
  });

  RideRequest.fromMap(Map<dynamic, dynamic> map) {
    riderName = map["rider_name"];
    riderPhone = map["rider_phone"];
    pickup = LatLng(map["pickup"]["latitude"], map["pickup"]["longitude"]);
    dropoff = LatLng(map["dropoff"]["latitude"], map["dropoff"]["longitude"]);
    rideRequestId = map["ride_request_id"];
  }
}
