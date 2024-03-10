import 'package:flutter/material.dart';
import 'package:tildesu_teacher/src/screens/common/admin_home.dart';

void main() {
  runApp(AdminApp());
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
      home: AdminHome(),
    );
  }
}
