import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/AllScreens/searchScreen.dart';
import 'package:rider_app/AllWidgets/Divider.dart';
import 'package:rider_app/Assistants/assistantMethods.dart';
import 'package:rider_app/DataHandler/appData.dart';

class MainScreen extends StatefulWidget
{
  static const String idScreen = "mainScreen";
  const MainScreen({Key key}) : super(key: key);
  
  @override
  _MainScreenState createState() => _MainScreenState();
}




class _MainScreenState extends State<MainScreen>
{
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Position currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap=0;

  void locatePosition() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition= position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    //Camera move
    CameraPosition cameraPosition = new CameraPosition(target: latLatPosition, zoom: 16);
    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    //newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address = await AssistantMethods.searchCoordinateAddress(position, context);
    print("This is your address :: " + address);
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Main Screen"),
      ),

      drawer: Container(
        color: Colors.white70,
        width: 255.0,
        child: Drawer(
          child: ListView(
            //Header
            children: [
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white70),
                  child: Row(
                    children: [
                      Image.asset("images/user_icon.png", height: 65.0, width: 65.0,),
                      SizedBox(width: 16.0,),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Nom de profil", style: TextStyle(fontSize: 16.0, fontFamily: "Brand-Bold"),),
                          SizedBox(height: 6.0,),
                          Text("Visitez votre profil"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              DividerWidget(),

              SizedBox(height: 12.0,),
              //Body controller
              ListTile(
                leading: Icon(Icons.history),
                title: Text("Historique", style: TextStyle(fontSize: 15.0),),
              ),

              ListTile(
                leading: Icon(Icons.person),
                title: Text("Visitez votre profil", style: TextStyle(fontSize: 15.0),),
              ),

              ListTile(
                leading: Icon(Icons.history),
                title: Text("À propos", style: TextStyle(fontSize: 15.0),),
              )
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap= 300.0;
              });

              //locatePosition();
              locatePosition();
            },
          ),
              //HamburgerMenu drawer
              Positioned(
                top: 45.0,
                left: 22.0,
                child: GestureDetector(
                  onTap: ()
                  {
                    scaffoldKey.currentState.openDrawer();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.circular(22.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 6.0,
                          spreadRadius: 0.5,
                          offset: Offset(
                            0.7,
                            0.7,
                          ),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.cyan,
                      child: Icon(Icons.menu, color: Colors.black26,),
                      radius: 20.0,
                    ),

                  ),
                ),
              ),

              //Where are you going panel
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              height: 300.0,
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6.0),
                    Text("Bienvenu(e)", style: TextStyle(fontSize: 16.0),),
                    Text("Où allez vous", style: TextStyle(fontSize: 20.0, fontFamily: "Brand-Bold"),),
                    SizedBox(height: 20.0),

                    GestureDetector(
                      onTap: ()
                      {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> SearchScreen()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white54,
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 6.0,
                              spreadRadius: 0.5,
                              offset: Offset(0.7, 0.7),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.cyanAccent,),
                              SizedBox(width: 10.0,),
                              Text("Entrez votre destination...")
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24.0),
                    Row(
                      children: [
                        Icon(Icons.home, color: Colors.grey,),
                        SizedBox(width: 18.0,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Provider.of<AppData>(context).pickUpLocation != null
                                  ? Provider.of<AppData>(context).pickUpLocation.placeName
                                  : "Indiquez l'adresse de votre travail",
                            ),
                            SizedBox(height: 4.0,),
                            Text("Indiquez l'adresse de votre domicile", style: TextStyle(color: Colors.cyan, fontSize: 14.0),),
                          ],
                        )
                      ],
                    ),

                    SizedBox(height: 10.0),
                    DividerWidget(),

                    SizedBox(height: 6.0),
                    Row(
                      children: [
                        Icon(Icons.work, color: Colors.grey,),
                        SizedBox(width: 18.0,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Ajouter un travail"),
                            SizedBox(height: 4.0,),
                            Text("L'adresse de votre bureau", style: TextStyle(color: Colors.cyan, fontSize: 14.0),),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
