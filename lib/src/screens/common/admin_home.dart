import 'package:flutter/material.dart';
import 'package:tildesu_teacher/src/screens/puzzles/puzzles_screen.dart';
import 'package:tildesu_teacher/src/screens/quizzes/quizzes_screen.dart';
import 'package:tildesu_teacher/src/screens/true_or_false/true_or_false_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TildeSU Admin'),
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
