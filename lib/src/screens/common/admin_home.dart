import 'package:flutter/material.dart';
import 'package:tildesu_teacher/src/screens/chat/chat_screen.dart';
import 'package:tildesu_teacher/src/screens/lessons/lessons_screen.dart';
import 'package:tildesu_teacher/src/screens/puzzles/puzzles_screen.dart';
import 'package:tildesu_teacher/src/screens/quizzes/quizzes_screen.dart';
import 'package:tildesu_teacher/src/screens/true_or_false/true_or_false_screen.dart';
import 'package:tildesu_teacher/src/screens/useful_tips/useful_tips.dart';
import 'package:tildesu_teacher/src/services/auth_service.dart';

import '../authentication/authentication_screen.dart';
import '../dictionary_cards/dictionary_cards_screen.dart';
import '../image_quiz/image_quiz_screen.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return QuizzesScreen();
      case 1:
        return PuzzlesScreen();
      case 2:
        return TrueOrFalseScreen();
      case 3:
        return DictionaryCardsScreen();
      case 4:
        return ImageQuizzesScreen();
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
                _signOut(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _signOut(BuildContext context) async {
    await AuthService().signOut(); // Sign out from Firebase Auth
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => AuthenticationScreen()),
          (Route<dynamic> route) => false,
    );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit App'),
        content: Text('Do you really want to exit the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'TildeSU Admin',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF34559C),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: () => _confirmSignOut(context),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Admin Menu', style: TextStyle(color: Colors.white)),
                decoration: BoxDecoration(
                  color: Color(0xFF34559C),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.book),
                title: Text('Lessons'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LessonsScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.lightbulb),
                title: Text('Useful Tips'), // New drawer item for Useful Tips
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UsefulTipsScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.chat),
                title: Text('Chat'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen()));
                },
              ),
            ],
          ),
        ),
        body: Center(
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
            BottomNavigationBarItem(
              icon: Icon(Icons.abc),
              label: 'Dictionary',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_chart_sharp),
              label: 'Image Quiz',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: const Color(0xFF34559C),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
