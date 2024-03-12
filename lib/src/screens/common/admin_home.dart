import 'package:flutter/material.dart';
import 'package:tildesu_teacher/src/screens/puzzles/puzzles_screen.dart';
import 'package:tildesu_teacher/src/screens/quizzes/quizzes_screen.dart';
import 'package:tildesu_teacher/src/screens/true_or_false/true_or_false_screen.dart';
import 'package:tildesu_teacher/src/services/auth_service.dart'; // Import your authentication service

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;

  // Updated to a function to create a new instance of the screen on each call
  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return QuizzesScreen();
      case 1:
        return PuzzlesScreen();
      case 2:
        return TrueOrFalseScreen();
      default:
        return QuizzesScreen(); // Default case
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Sign Out'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to sign out?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Sign Out'),
              onPressed: () {
                Navigator.of(context).pop();
                _signOut(context); // Call the sign-out method
              },
            ),
          ],
        );
      },
    );
  }

  void _signOut(BuildContext context) {
    // Call your sign-out method from the authentication service
    AuthService().signOut();
    // Navigate back to the authentication screen or any other screen
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TildeSU Admin',
          style: TextStyle(color: Colors.white), // Set text color to white
        ),
        backgroundColor: Color(0xFF34559C), // Set the app bar color to #34559C
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _confirmSignOut(context), // Call _confirmSignOut method on button press
          ),
        ],
      ),
      body: Center(
        // Dynamically get the current screen based on _selectedIndex
        child: _getScreen(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer),
            label: 'Quizzes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.extension),
            label: 'Puzzles',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'True/False',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
