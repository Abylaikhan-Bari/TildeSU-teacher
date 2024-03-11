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

      // Add to Firestore
      FirebaseFirestore.instance.collection('levels').doc('A1').collection('quizzes').add(exerciseData).then((result) {
        // Clear the form or navigate away
        _clearForm();
      }).catchError((error) {
        // Handle errors here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add quiz: $error')),
        );
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Quiz Exercise'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(labelText: 'Question'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the question';
                  }
                  return null;
                },
              ),
              ...List.generate(4, (index) {
                // Generating text fields for 4 options
                return TextFormField(
                  controller: [ _option1Controller, _option2Controller, _option3Controller, _option4Controller ][index],
                  decoration: InputDecoration(labelText: 'Option ${index + 1}'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an option';
                    }
                    return null;
                  },
                );
              }),
              DropdownButtonFormField<int>(
                value: _correctOptionIndex,
                onChanged: (int? newValue) {
                  setState(() {
                    _correctOptionIndex = newValue!;
                  });
                },
                items: List<DropdownMenuItem<int>>.generate(
                  4, // The number of options
                      (index) => DropdownMenuItem<int>(
                    value: index,
                    child: Text('Option ${index + 1}'),
                  ),
                ),
                decoration: InputDecoration(labelText: 'Correct Option'),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _addQuiz,
                  child: Text('Add Quiz'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
