import 'package:flex_ride/AllScreens/driver_applications_list_screen.dart';
import 'package:flex_ride/AllWidgets/toast.dart';
import 'package:flutter/material.dart';

class AdminPanelScreen extends StatefulWidget {
  static const String idScreen = "adminPanel";

  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Panneau d'administration"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mot de passe administrateur",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // For simplicity, we'll use a hardcoded password.
                // In a real app, this should be handled securely.
                if (_passwordController.text == "password") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriverApplicationsListScreen(),
                    ),
                  );
                } else {
                  displayToastMessage("Mot de passe incorrect.", context);
                }
              },
              child: const Text("Connexion"),
            ),
          ],
        ),
      ),
    );
  }
}
