import 'package:flex_ride/models/vehicle_type.dart';
import 'package:flex_ride/Assistants/requestAssistant.dart';
import 'package:flex_ride/DataHandler/appData.dart';
import 'package:flex_ride/Models/address.dart';
import 'package:flex_ride/Models/directDetails.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(Position position, context) async {
    String placeAddress = "";
    final apiKey = dotenv.env['MAPS_API_KEY'];
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey";

    var response = await RequestAssistant.getRequest(url);

    if (response != "failed") {
      placeAddress = response["results"][0]["formatted_address"];

      Address userPickUpAddress = Address();
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }

    return placeAddress;
  }

  static Future<DirectionDetails?> obtainPlaceDirectionDetails(LatLng initialPosition, LatLng finalPosition) async {
    final apiKey = dotenv.env['MAPS_API_KEY'];
    String directionUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$apiKey";

    var res = await RequestAssistant.getRequest(directionUrl);

    if (res == "failed") {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints = res["routes"][0]["overview_polyline"]["points"];
    directionDetails.distanceText = res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue = res["routes"][0]["legs"][0]["distance"]["value"];
    directionDetails.durationText = res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue = res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }

  static int calculateFares(DirectionDetails directionDetails, VehicleType vehicleType) {
    // 1 USD = 600 NGN
    double timeTraveledFare = (directionDetails.durationValue! / 60) * 0.20 * 600;
    double distanceTraveledFare = (directionDetails.distanceValue! / 1000) * 0.20 * 600;
    double totalFareAmount = timeTraveledFare + distanceTraveledFare;

    switch (vehicleType) {
      case VehicleType.Car:
        totalFareAmount *= 1.0;
        break;
      case VehicleType.Tricycle:
        totalFareAmount *= 0.8;
        break;
      case VehicleType.Motorcycle:
        totalFareAmount *= 0.6;
        break;
    }

    return totalFareAmount.truncate();
  }
}
