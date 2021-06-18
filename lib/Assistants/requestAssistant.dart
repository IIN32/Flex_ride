import 'dart:convert';
//import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:rider_app/configMaps.dart';
import 'package:rider_app/lib/AllScreens/mainscreen.dart';

class RequestAssistant
{

   static Future<dynamic> getRequest(url) async
  {
    //ADDED FROM MAINSCREEN
    //Position currentPosition;
    //var geoLocator = Geolocator();
    //double bottomPaddingOfMap=0;
    //ADDED FROM MAINSCREEN, STOP AT POSITION BEFORE COMMENT
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    //currentPosition= position;
    //var response = await http.post(Uri.parse(url));

    var url = Uri.parse("https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyA0aN2vF4H5jmnzRTSa9jZnfsGr1T_W35Q");


    //http.Response response = await http.get(Uri.parse(url as String));

    http.Response response = await http.get(url);

    try
    {
      if(response.statusCode==200)
      {
        String jSonData = response.body;
        var decodeData = jsonDecode(jSonData);
        return decodeData;
      }
      else
      {
        return "failed";
      }
    }
    catch(exp)
    {
      return "failed";
    }
  }
}