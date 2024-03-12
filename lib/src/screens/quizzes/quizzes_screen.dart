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

  Future<void> _addQuiz() async {
    if (_formKey.currentState!.validate()) {
      final quizData = {
        'question': _questionController.text.trim(),
        'options': [
          _option1Controller.text.trim(),
          _option2Controller.text.trim(),
          _option3Controller.text.trim(),
          _option4Controller.text.trim(),
        ],
        'correctOptionIndex': _correctOptionIndex, // This is already an int
      };

      // Retrieve all quiz document IDs to find the highest number
      final querySnapshot = await FirebaseFirestore.instance
          .collection('levels')
          .doc(_selectedLevel)
          .collection('quizzes')
          .get();

      final List<DocumentSnapshot> documents = querySnapshot.docs;
      // Find the last quiz ID
      int highestId = documents.fold<int>(0, (previousValue, document) {
        final idString = document.id.replaceAll(RegExp(r'[^0-9]'), '');
        final id = int.tryParse(idString) ?? 0;
        return id > previousValue ? id : previousValue;
      });

      // Generate the next quiz ID
      final nextQuizId = 'quizId${highestId + 1}';

      try {
        await FirebaseFirestore.instance
            .collection('levels')
            .doc(_selectedLevel)
            .collection('quizzes')
            .doc(nextQuizId) // Use the next available ID
            .set(quizData);

        _clearForm();
      } catch (error) {
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
      final quizData = {
        'question': _questionController.text.trim(),
        'options': [
          _option1Controller.text.trim(),
          _option2Controller.text.trim(),
          _option3Controller.text.trim(),
          _option4Controller.text.trim(),
        ],
        'correctOptionIndex': _correctOptionIndex, // Make sure this is set as an int
      };

      try {
        await FirebaseFirestore.instance
            .collection('levels')
            .doc(_selectedLevel)
            .collection('quizzes')
            .doc(quizId) // Use the existing quiz ID
            .update(quizData);

        _clearForm();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quiz: $error')),
        );
      }
    }
  }


  Future<void> _deleteQuiz(String quizId) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Quiz'),
          content: Text('Are you sure you want to delete this quiz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('levels')
                      .doc(_selectedLevel)
                      .collection('quizzes')
                      .doc(quizId)
                      .delete();
                  Navigator.of(context).pop();
                } catch (error) {
                  // Handle error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete quiz: $error')),
                  );
                }
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  String _translate(String key) {
    // Here you would implement logic to translate the key to the appropriate language
    // For now, let's return the key as is
    return key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_translate('Quizzes for Level') + ' $_selectedLevel'),
        backgroundColor: Color(0xFF34559C), // Set the app bar color to #34559C
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
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  final quizzes = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = quizzes[index];
                      return Card(
                        child: ListTile(
                          title: Text(_translate('Quiz') + ' ${quiz.id}'),
                          onTap: () {
                            // Show dialog to update quiz
                            _questionController.text = quiz['question'];
                            _option1Controller.text = quiz['options'][0];
                            _option2Controller.text = quiz['options'][1];
                            _option3Controller.text = quiz['options'][2];
                            _option4Controller.text = quiz['options'][3];
                            _correctOptionIndex = quiz['correctOptionIndex'];
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(_translate('Update Quiz')),
                                  content: Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        TextFormField(
                                          controller: _questionController,
                                          decoration: InputDecoration(labelText: _translate('Question')),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return _translate('Please enter a question');
                                            }
                                            return null;
                                          },
                                        ),
                                        TextFormField(
                                          controller: _option1Controller,
                                          decoration: InputDecoration(labelText: _translate('Option 1')),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return _translate('Please enter option 1');
                                            }
                                            return null;
                                          },
                                        ),
                                        TextFormField(
                                          controller: _option2Controller,
                                          decoration: InputDecoration(labelText: _translate('Option 2')),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return _translate('Please enter option 2');
                                            }
                                            return null;
                                          },
                                        ),
                                        TextFormField(
                                          controller: _option3Controller,
                                          decoration: InputDecoration(labelText: _translate('Option 3')),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return _translate('Please enter option 3');
                                            }
                                            return null;
                                          },
                                        ),
                                        TextFormField(
                                          controller: _option4Controller,
                                          decoration: InputDecoration(labelText: _translate('Option 4')),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return _translate('Please enter option 4');
                                            }
                                            return null;
                                          },
                                        ),
                                        TextFormField(
                                          initialValue: _correctOptionIndex.toString(),
                                          decoration: InputDecoration(labelText: _translate('Correct Option Index')),
                                          keyboardType: TextInputType.number,
                                          onChanged: (value) {
                                            setState(() {
                                              _correctOptionIndex = int.tryParse(value) ?? 0;
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return _translate('Please enter the correct option index');
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(_translate('Cancel')),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _updateQuiz(quiz.id);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(_translate('Update')),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              _deleteQuiz(quiz.id);
                            },
                          ),
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
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(_translate('Add Quiz')),
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _questionController,
                        decoration: InputDecoration(labelText: _translate('Question')),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _translate('Please enter a question');
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _option1Controller,
                        decoration: InputDecoration(labelText: _translate('Option 1')),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _translate('Please enter option 1');
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _option2Controller,
                        decoration: InputDecoration(labelText: _translate('Option 2')),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _translate('Please enter option 2');
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _option3Controller,
                        decoration: InputDecoration(labelText: _translate('Option 3')),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _translate('Please enter option 3');
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _option4Controller,
                        decoration: InputDecoration(labelText: _translate('Option 4')),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _translate('Please enter option 4');
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: _translate('Correct Option Index')),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _correctOptionIndex = int.tryParse(value) ?? 0;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _translate('Please enter the correct option index');
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(_translate('Cancel')),
                  ),
                  TextButton(
                    onPressed: () {
                      _addQuiz();
                      Navigator.of(context).pop();
                    },
                    child: Text(_translate('Add')),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
