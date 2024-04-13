import 'package:flutter/material.dart';

class LessonsScreen extends StatelessWidget {
  // Sample data for lessons
  final List<Map<String, dynamic>> lessons = [
    {
      'title': 'Lesson 1',
      'description': 'Introduction to the course',
    },
    {
      'title': 'Lesson 2',
      'description': 'Deep dive into topic 1',
    },
    // Add more lessons as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lessons'),
        backgroundColor: Color(0xFF34559C),
      ),
      body: ListView.builder(
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(lessons[index]['title']),
              subtitle: Text(lessons[index]['description']),
              onTap: () {
                // Handle navigation to the lesson details or content
                // For example: Navigator.pushNamed(context, '/lesson-details', arguments: lessons[index]);
              },
            ),
          );
        },
      ),
    );
  }
}