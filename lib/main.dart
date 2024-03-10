import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tildesu_teacher/src/screens/common/admin_home.dart';
import 'package:tildesu_teacher/src/screens/authentication/authentication_screen.dart';
import 'package:tildesu_teacher/src/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure platform services are initialized.
  await Firebase.initializeApp(); // Initialize Firebase.
  runApp(AdminApp()); // Run the app.
}

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TildeSU teacher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: StreamBuilder<User?>(
        stream: AuthService().user, // Listen to the auth state changes.
        builder: (context, snapshot) {
          // Check the connection state of the async snapshot.
          if (snapshot.connectionState == ConnectionState.active) {
            // Get the user from the snapshot.
            User? user = snapshot.data;

            // If the snapshot has a user data, the user is logged in, show AdminHome.
            // If the user is null, no user is logged in, show AuthenticationScreen.
            return user == null ? AuthenticationScreen() : AdminHome();
          }

          // While checking the auth state (e.g., loading the user), show a spinner.
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}
