import 'package:flutter/material.dart';
import 'package:tildesu_teacher/src/services/firestore_service.dart';
import 'package:tildesu_teacher/src/models/Lesson.dart';

class LessonsScreen extends StatefulWidget {
  @override
  _LessonsScreenState createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedLevel = 'A1';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _showAddEditLessonDialog({Lesson? lesson}) async {
    if (lesson != null) {
      _titleController.text = lesson.title;
      _descriptionController.text = lesson.description;
      _contentController.text = lesson.content;
    } else {
      _titleController.clear();
      _descriptionController.clear();
      _contentController.clear();
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lesson != null ? 'Edit Lesson' : 'Add Lesson'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(labelText: 'Content'),
                  maxLines: null,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                final newLesson = Lesson(
                  id: lesson?.id ?? '',
                  title: _titleController.text,
                  description: _descriptionController.text,
                  content: _contentController.text,
                );
                if (lesson != null) {
                  await _firestoreService.updateLesson(newLesson, _selectedLevel);
                } else {
                  await _firestoreService.addLesson(newLesson, _selectedLevel);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteLesson(String lessonId) async {
    await _firestoreService.deleteLesson(lessonId, _selectedLevel);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lessons for Level $_selectedLevel'),
        actions: <Widget>[
          DropdownButton<String>(
            value: _selectedLevel,
            icon: Icon(Icons.arrow_drop_down, color: Colors.white),
            iconSize: 24,
            elevation: 16,
            style: TextStyle(color: Colors.black),
            underline: Container(
              height: 2,
              color: const Color(0xFF34559C),
            ),
            onChanged: (String? newValue) {
              setState(() {
                _selectedLevel = newValue!;
              });
            },
            items: <String>['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),

        ],
        backgroundColor: const Color(0xFF34559C),
      ),
      body: StreamBuilder<List<Lesson>>(
        stream: _firestoreService.getLessonsForLevel(_selectedLevel),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No lessons found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final lesson = snapshot.data![index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(lesson.title),
                  subtitle: Text(lesson.description),
                  onTap: () => _showAddEditLessonDialog(lesson: lesson),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Lesson'),
                            content: Text('Are you sure you want to delete this lesson?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Delete'),
                                onPressed: () {
                                  _deleteLesson(lesson.id);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditLessonDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
