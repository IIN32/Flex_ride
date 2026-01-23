import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flex_ride/features/admin/screens/admin_panel_screen.dart';
import 'package:flex_ride/features/driver/screens/driver_application_screen.dart';
import 'package:flex_ride/features/driver/screens/driver_application_status_screen.dart';
import 'package:flex_ride/features/driver/screens/earnings_screen.dart';
import 'package:flex_ride/features/user/screens/emergency_contact_screen.dart';
import 'package:flex_ride/features/rider/screens/main_screen.dart';
import 'package:flex_ride/features/auth/screens/new_user_info_screen.dart';
import 'package:flex_ride/features/auth/screens/phone_auth_screen.dart';
import 'package:flex_ride/features/rider/screens/ride_history_screen.dart';
import 'package:flex_ride/DataHandler/appData.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

CollectionReference usersRef = FirebaseFirestore.instance.collection('users');

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Ride',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: PhoneAuthScreen.idScreen,
        routes: {
          MainScreen.idScreen: (context) => const MainScreen(),
          PhoneAuthScreen.idScreen: (context) => const PhoneAuthScreen(),
          DriverApplicationScreen.idScreen: (context) =>
              const DriverApplicationScreen(),
          DriverApplicationStatusScreen.idScreen: (context) =>
              const DriverApplicationStatusScreen(),
          EarningsScreen.idScreen: (context) => const EarningsScreen(),
          RideHistoryScreen.idScreen: (context) => const RideHistoryScreen(),
          EmergencyContactScreen.idScreen: (context) =>
              const EmergencyContactScreen(),
          AdminPanelScreen.idScreen: (context) => const AdminPanelScreen(),
          NewUserInfoScreen.idScreen: (context) => const NewUserInfoScreen(phone: ''),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
