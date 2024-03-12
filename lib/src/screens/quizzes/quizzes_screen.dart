import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizzesScreen extends StatefulWidget {
  @override
  _QuizzesScreenState createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  int _correctOptionIndex = 0; // Index of the correct option
  String _selectedLevel = 'A1'; // Default selected level

  @override
  void dispose() {
    _questionController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    super.dispose();
  }

  void _addQuiz() async {
    if (_formKey.currentState!.validate()) {
      final exerciseData = {
        'question': _questionController.text.trim(),
        'options': [
          _option1Controller.text.trim(),
          _option2Controller.text.trim(),
          _option3Controller.text.trim(),
          _option4Controller.text.trim(),
        ],
        'correctOptionIndex': _correctOptionIndex,
      };

      try {
        await FirebaseFirestore.instance
            .collection('levels')
            .doc(_selectedLevel)
            .collection('quizzes')
            .add(exerciseData);
        _clearForm();
      } catch (error) {
        // Handle errors here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add quiz: $error')),
        );
      }
    }
  }

  void _clearForm() {
    _questionController.clear();
    _option1Controller.clear();
    _option2Controller.clear();
    _option3Controller.clear();
    _option4Controller.clear();
    setState(() {
      _correctOptionIndex = 0;
    });
  }

  Future<void> _updateQuiz(String quizId) async {
    if (_formKey.currentState!.validate()) {
      final exerciseData = {
        'question': _questionController.text.trim(),
        'options': [
          _option1Controller.text.trim(),
          _option2Controller.text.trim(),
          _option3Controller.text.trim(),
          _option4Controller.text.trim(),
        ],
        'correctOptionIndex': _correctOptionIndex,
      };

      try {
        await FirebaseFirestore.instance
            .collection('levels')
            .doc(_selectedLevel)
            .collection('quizzes')
            .doc(quizId)
            .update(exerciseData);
        _clearForm();
      } catch (error) {
        // Handle errors here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quiz: $error')),
        );
      }
    }
  }

  Future<void> _deleteQuiz(String quizId) async {
    try {
      await FirebaseFirestore.instance
          .collection('levels')
          .doc(_selectedLevel)
          .collection('quizzes')
          .doc(quizId)
          .delete();
    } catch (error) {
      // Handle errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete quiz: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quizzes for Level $_selectedLevel'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: _selectedLevel,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedLevel = newValue;
                });
              }
            },
            items: <String>['A1', 'A2', 'B1', 'B2', 'C1', 'C2'] // Add more levels if needed
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('levels')
                  .doc(_selectedLevel)
                  .collection('quizzes')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  final quizzes = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = quizzes[index];
                      return ListTile(
                        title: Text('Quiz ${quiz.id}'),
                        onTap: () {
                          // Implement functionality to view or edit quiz details
                          // For simplicity, let's just fill the form with quiz data for now
                          _questionController.text = quiz['question'];
                          _option1Controller.text = quiz['options'][0];
                          _option2Controller.text = quiz['options'][1];
                          _option3Controller.text = quiz['options'][2];
                          _option4Controller.text = quiz['options'][3];
                          _correctOptionIndex = quiz['correctOptionIndex'];
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteQuiz(quiz.id);
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuiz,
        child: Icon(Icons.add),
      ),
    );
  }
}
