//import 'dart:html';

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/AllWidgets/Divider.dart';
import 'package:rider_app/Assistants/requestAssistant.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/Models/placePredictions.dart';
//import 'package:rider_app/configMaps.dart';

class SearchScreen extends StatefulWidget {
  //const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
{
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  List<PlacePredictions> placePredictionList = [];

  @override
  Widget build(BuildContext context)
  {
    String placeAddress= Provider.of<AppData>(context).pickUpLocation.placeName ?? "";
    pickUpTextEditingController.text= placeAddress;

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 215.0,
            decoration: BoxDecoration(
              color: Colors.white70,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7),
                ),
              ],
            ),

            child: Padding(
              padding: EdgeInsets.only(left: 25.0, top: 55.0, right: 25.0, bottom: 20.0),
              child: Column(
                children: [
                  SizedBox(height: 5.0),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap:()
                        {
                          Navigator.pop(context);
                        },
                        child: Icon(
                            Icons.arrow_back
                        ),
                      ),
                      Center(
                        child: Text("Définir la destination", style: TextStyle(fontSize: 18.0, fontFamily: "Brand-Bold"),),
                      )
                    ],
                  ),

                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Image.asset("images/pickicon.png", height: 16.0, width: 16.0,),

                      SizedBox(width: 18.0,),

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              controller: pickUpTextEditingController,
                              decoration: InputDecoration(
                                hintText: "Définir votre position de prise...",
                                fillColor: Colors.greenAccent[400],
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(left: 11.0, top: 8.0, bottom: 8.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.0),
                  Row(
                    children: [
                      Image.asset("images/desticon0.png", height: 16.0, width: 16.0,),

                      SizedBox(width: 18.0,),

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(3.0),
                            child: TextField(
                              onChanged: (val)
                              {
                                findPlace(val);
                              },
                              controller: dropOffTextEditingController,
                              decoration: InputDecoration(
                                hintText: "Où allez-vous ?",
                                fillColor: Colors.greenAccent[400],
                                filled: true,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.only(left: 11.0, top: 8.0, bottom: 8.0),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),

                ],
              ),
            ),
          ),

          //predictions

          (placePredictionList.length > 0)
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListView.separated(
                    padding: EdgeInsets.all(0.0),
                    itemBuilder: (context, index)
                    {
                      return PredictionTile(placePredictions: placePredictionList[index],);
                    },
                    separatorBuilder: (BuildContext context, int index) => DividerWidget(),
                    itemCount: placePredictionList.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  ),
          )
              :Container(),
        ]
      ),
    );
  }

  void findPlace(String placeName) async
  {
    if(placeName.length > 1)
    {
      String autoCompleteUrl = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=AIzaSyA0aN2vF4H5jmnzRTSa9jZnfsGr1T_W35Q&sessiontoken=1234567890&components=country:ne";

      var res = await RequestAssistant.getRequest(autoCompleteUrl);


      if (res == "failed")
      {
        return;
      }
      print("Places Predictions Response :: ");
      print(res);

      if(res["status"] == "OK")
      {
        var predictions = res["predictions"];

        var placesList = (predictions as List).map((e) => PlacePredictions.fromJson(e)).toList();

        setState(() {
          placePredictionList = placesList;
        });
      }
    }
  }
}


class PredictionTile extends StatelessWidget
{
  static List<Map<String, dynamic>> reservations = [];
  final PlacePredictions placePredictions;
  const PredictionTile({Key key, this.placePredictions}) : super(key: key);

  @override
  Widget build(BuildContext context)
  {
    return Container(
      child: Column(

        children: [
          Row(
            children: [
              SizedBox(width: 14.0),
              Icon(Icons.add_location),
              SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(placePredictions.main_text,overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16.0),),
                    SizedBox(height: 3.0,),
                    Text(placePredictions.secondary_text,overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.0, color: Colors.grey),),
                  ],
                ),
              )
            ],
          ),

          SizedBox(width: 10.0),
        ],
      )
    );
  }
}
