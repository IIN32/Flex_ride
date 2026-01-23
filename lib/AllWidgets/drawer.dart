import 'package:flex_ride/features/admin/screens/admin_panel_screen.dart';
import 'package:flex_ride/features/driver/screens/driver_application_screen.dart';
import 'package:flex_ride/features/driver/screens/driver_application_status_screen.dart';
import 'package:flex_ride/features/driver/screens/earnings_screen.dart';
import 'package:flex_ride/features/user/screens/emergency_contact_screen.dart';
import 'package:flex_ride/features/rider/screens/ride_history_screen.dart';
import 'package:flex_ride/shared/widgets/divider_widget.dart';
import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70,
      width: 255.0,
      child: Drawer(
        child: ListView(
          //Header
          children: [
            SizedBox(
              height: 165.0,
              child: DrawerHeader(
                decoration: const BoxDecoration(color: Colors.white70),
                child: Row(
                  children: [
                    Image.asset(
                      "images/user_icon.png",
                      height: 65.0,
                      width: 65.0,
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Nom de profil",
                          style: TextStyle(fontSize: 16.0, fontFamily: "Brand-Bold"),
                        ),
                        SizedBox(
                          height: 6.0,
                        ),
                        Text("Visitez votre profil"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const DividerWidget(),
            const SizedBox(
              height: 12.0,
            ),
            //Body controller
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, RideHistoryScreen.idScreen);
              },
              leading: const Icon(Icons.history),
              title: const Text(
                "Historique",
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.person),
              title: Text(
                "Visitez votre profil",
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, DriverApplicationScreen.idScreen);
              },
              leading: const Icon(Icons.drive_eta),
              title: const Text(
                "Devenir chauffeur",
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pushNamed(
                    context, DriverApplicationStatusScreen.idScreen);
              },
              leading: const Icon(Icons.check_circle_outline),
              title: const Text(
                "Statut de la demande",
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, EarningsScreen.idScreen);
              },
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text(
                "Gains",
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, EmergencyContactScreen.idScreen);
              },
              leading: const Icon(Icons.contact_emergency),
              title: const Text(
                "Contact d'urgence",
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.pushNamed(context, AdminPanelScreen.idScreen);
              },
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text(
                "Panneau d'administration",
                style: TextStyle(fontSize: 15.0),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.history),
              title: Text(
                "À propos",
                style: TextStyle(fontSize: 15.0),
              ),
            )
          ],
        ),
      ),
    );
  }
}
