 //import 'dart:js';

import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/Assistants/requestAssistant.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Models/address.dart';
import 'package:rider_app/configMaps.dart';

class AssistantMethods
{
  static Future<String> searchCoordinateAddress(Position position, context) async
  {
    String placeAddress = "";
    String st1, st2, st3; // st4;
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyA0aN2vF4H5jmnzRTSa9jZnfsGr1T_W35Q";

    print(position.latitude);
    print(position.longitude);

    var response = await RequestAssistant.getRequest(url);

    print(response);

    if(response != "failed")
    {
      //placeAddress = response["results"][0]["formatted_address"];
      //DISPLAY HOUSE AND OFFICE NUMBERS
      st1 = response["results"][0]["address_components"][0]["short_name"];
      st2 = response["results"][0]["address_components"][1]["short_name"];
      st3 = response["results"][0]["address_components"][3]["short_name"];
      //st4 = response["results"][0]["address_components"][4]["short_name"];

      placeAddress = st1 + ", " + st2 + ", " + st3; // + ", " + st4;

      Address userPickUpAddress = new Address();
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.placeName = placeAddress;


      Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }

    return placeAddress;
  }
}