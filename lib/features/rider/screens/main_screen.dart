import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_ride/features/rider/screens/ride_preview_screen.dart';
import 'package:flex_ride/features/rider/screens/search_screen.dart';
import 'package:flex_ride/shared/widgets/divider_widget.dart';
import 'package:flex_ride/shared/widgets/app_drawer.dart';
import 'package:flex_ride/shared/widgets/progress_dialog.dart';
import 'package:flex_ride/Assistants/assistantMethods.dart';
import 'package:flex_ride/DataHandler/appData.dart';
import 'package:flex_ride/Models/directDetails.dart';
import 'package:flex_ride/Models/ride_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

enum AppMode {
  Rider,
  Driver,
}

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";

  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  Position? currentPosition;
  var geoLocator = Geolocator();
  double bottomPaddingOfMap = 0;
  bool isDriverOnline = false;
  AppMode appMode = AppMode.Rider;

  DocumentReference? rideRequestRef;
  StreamSubscription<Position>? rideStreamSubscription;
  RideRequest? currentRide;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    listenForRideRequests();
  }

  void listenForRideRequests() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user != null) {
      rideRequestRef = FirebaseFirestore.instance
          .collection('drivers')
          .doc(user.uid)
          .collection("newRide")
          .doc("rideDetails");

      rideRequestRef?.snapshots().listen((doc) {
        if (doc.exists) {
          RideRequest rideRequest = RideRequest.fromMap(doc.data() as Map);
          setState(() {
            currentRide = rideRequest;
          });
          showRideRequestDialog(rideRequest);
        }
      });
    }
  }

  void showRideRequestDialog(RideRequest rideRequest) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Nouvelle demande de course"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Passager: ${rideRequest.riderName}"),
            Text("Téléphone: ${rideRequest.riderPhone}"),
            Text("De: ${rideRequest.pickup}"),
            Text("À: ${rideRequest.dropoff}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              acceptRideRequest(rideRequest);
            },
            child: const Text("Accepter"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              rejectRideRequest(rideRequest);
            },
            child: const Text("Rejeter"),
          ),
        ],
      ),
    );
  }

  void acceptRideRequest(RideRequest rideRequest) {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference rideRef = FirebaseFirestore.instance
          .collection('rides')
          .doc(rideRequest.rideRequestId!);
      rideRef.update({"status": "accepted", "driver_id": user.uid});
      rideRequestRef?.delete();
      getRideLiveLocationUpdates(rideRequest.rideRequestId!);
    }
  }

  void rejectRideRequest(RideRequest rideRequest) {
    rideRequestRef?.delete();
  }

  void getRideLiveLocationUpdates(String rideRequestId) {
    rideStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      DocumentReference rideRef = FirebaseFirestore.instance.collection('rides').doc(rideRequestId);
      rideRef.update({
        "driver_location": {
          "latitude": currentPosition!.latitude,
          "longitude": currentPosition!.longitude,
        }
      });
    });
  }

  Future<void> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      if (await Permission.location.request().isGranted) {
        locatePosition();
      }
    } else if (status.isGranted) {
      locatePosition();
    }
  }

  void locatePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      currentPosition = position;

      LatLng latLatPosition = LatLng(position.latitude, position.longitude);
      //Camera move
      CameraPosition cameraPosition =
          CameraPosition(target: latLatPosition, zoom: 16);
      newGoogleMapController
          ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      String address =
          await AssistantMethods.searchCoordinateAddress(position, context);
      print("This is your address :: " + address);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(appMode == AppMode.Rider ? "Rider" : "Driver"),
        actions: [
          Switch(
            value: appMode == AppMode.Driver,
            onChanged: (value) {
              setState(() {
                appMode = value ? AppMode.Driver : AppMode.Rider;
              });
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
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
            polylines: polylineSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              setState(() {
                bottomPaddingOfMap = 300.0;
              });

              locatePosition();
            },
          ),
          //HamburgerMenu drawer
          Positioned(
            top: 45.0,
            left: 22.0,
            child: GestureDetector(
              onTap: () {
                scaffoldKey.currentState?.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(22.0),
                  boxShadow: const [
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
                child: const CircleAvatar(
                  backgroundColor: Colors.cyan,
                  radius: 20.0,
                  child: Icon(
                    Icons.menu,
                    color: Colors.black26,
                  ),
                ),
              ),
            ),
          ),

          if (appMode == AppMode.Rider)
            //Rider Panel
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Container(
                height: 300.0,
                decoration: const BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0)),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6.0),
                      const Text(
                        "Bienvenu(e)",
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const Text(
                        "Où allez vous",
                        style: TextStyle(fontSize: 20.0, fontFamily: "Brand-Bold"),
                      ),
                      const SizedBox(height: 20.0),
                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SearchScreen()));

                          if (res == "obtainDirection") {
                            await getPlaceDirection();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 6.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              ),
                            ],
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.cyanAccent,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text("Entrez votre destination...")
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Row(
                        children: [
                          const Icon(
                            Icons.home,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 18.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Provider.of<AppData>(context).pickUpLocation != null
                                    ? Provider.of<AppData>(context)
                                        .pickUpLocation!
                                        .placeName!
                                    : "Indiquez l'adresse de votre travail",
                              ),
                              const SizedBox(
                                height: 4.0,
                              ),
                              const Text(
                                "Indiquez l'adresse de votre domicile",
                                style: TextStyle(
                                    color: Colors.cyan, fontSize: 14.0),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      const DividerWidget(),
                      const SizedBox(height: 6.0),
                      Row(
                        children: [
                          const Icon(
                            Icons.work,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 18.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Ajouter un travail"),
                              const SizedBox(
                                height: 4.0,
                              ),
                              const Text(
                                "L'adresse de votre bureau",
                                style: TextStyle(
                                    color: Colors.cyan, fontSize: 14.0),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            //Driver Panel
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: Container(
                height: 300.0,
                decoration: const BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0)),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6.0),
                      const Text(
                        "You are a Driver",
                        style: TextStyle(fontSize: 16.0),
                      ),
                      Switch(
                        value: isDriverOnline,
                        onChanged: (value) {
                          setState(() {
                            isDriverOnline = value;
                          });
                          updateDriverOnlineStatus(isDriverOnline);
                        },
                        activeTrackColor: Colors.lightGreenAccent,
                        activeColor: Colors.green,
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

  Future<void> getPlaceDirection() async {
    var initialPos = Provider.of<AppData>(context, listen: false).pickUpLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos!.latitude!, initialPos.longitude!);
    var dropOffLatLng = LatLng(finalPos!.latitude!, finalPos.longitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) => const ProgressDialog(
              message: "Veuillez patienter...",
            ));

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    Navigator.pop(context);

    if (details == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RidePreviewScreen(directionDetails: details),
      ),
    );
  }

  void updateDriverOnlineStatus(bool isOnline) {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference driverRef =
        FirebaseFirestore.instance.collection('drivers').doc(userId);
    driverRef.update({"isOnline": isOnline});

    if (isOnline) {
      getRideLiveLocationUpdates("rideRequestId"); //This is a placeholder
    } else {
      rideStreamSubscription?.cancel();
    }
  }
}
