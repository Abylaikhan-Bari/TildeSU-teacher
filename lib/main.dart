import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tildesu_teacher/src/screens/common/admin_home.dart';
import 'package:tildesu_teacher/src/screens/authentication/authentication_screen.dart';
import 'package:tildesu_teacher/src/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with proper options
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyCspjGTiiyGEvBkO_koBj_H_vcvrLS9Gi8",
          authDomain: "tildesu-9a77e.firebaseapp.com",
          databaseURL: "https://tildesu-9a77e-default-rtdb.europe-west1.firebasedatabase.app",
          projectId: "tildesu-9a77e",
          storageBucket: "tildesu-9a77e.appspot.com",
          messagingSenderId: "37665738009",
          appId: "1:37665738009:web:707a5abd1d9c4b3e188988",
          measurementId: "G-DDQSE091YB"
      ),
    );

    runApp(AdminApp());
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
}

class AdminApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TildeSU admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: StreamBuilder<User?>(
        stream: AuthService().user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            return user == null ? AuthenticationScreen() : AdminHome();
          }
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
