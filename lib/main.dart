import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tildesu_teacher/src/screens/common/admin_home.dart';
import 'package:tildesu_teacher/src/screens/authentication/authentication_screen.dart';
import 'package:tildesu_teacher/src/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(AdminApp());
}

class AdminApp extends StatelessWidget {
  // Create an instance of AuthService to listen to the authentication changes
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TildeSU teacher',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      // Use StreamBuilder to listen to the authentication state changes
      home: StreamBuilder<User?>(
        stream: _authService.user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // Check if the snapshot has data, which indicates the user is logged in
            User? user = snapshot.data;
            if (user != null) {
              // If the user is logged in, show the AdminHome screen
              return AdminHome();
            }
            // If the user is not logged in, show the AuthenticationScreen
            return AuthenticationScreen();
          }
          // While the connection to Firebase is being established, show a loading indicator
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
