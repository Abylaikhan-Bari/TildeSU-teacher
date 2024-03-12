import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrueOrFalseScreen extends StatefulWidget {
  @override
  _TrueOrFalseScreenState createState() => _TrueOrFalseScreenState();
}

class _TrueOrFalseScreenState extends State<TrueOrFalseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _statementController = TextEditingController();
  bool _isTrue = true; // Default to true
  String _selectedLevel = 'A1'; // Default selected level

  @override
  void dispose() {
    _statementController.dispose();
    super.dispose();
  }

  void _addTrueOrFalseExercise() async {
    if (_formKey.currentState!.validate()) {
      final exerciseData = {
        'statement': _statementController.text.trim(),
        'isTrue': _isTrue,
      };

      try {
        await FirebaseFirestore.instance
            .collection('levels')
            .doc(_selectedLevel)
            .collection('trueOrFalse')
            .add(exerciseData);
        _clearForm();
      } catch (error) {
        // Handle errors here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add true or false exercise: $error')),
        );
      }
    }
  }

  void _clearForm() {
    _statementController.clear();
    setState(() {
      _isTrue = true;
    });
  }

  Future<void> _updateTrueOrFalseExercise(String exerciseId) async {
    if (_formKey.currentState!.validate()) {
      final exerciseData = {
        'statement': _statementController.text.trim(),
        'isTrue': _isTrue,
      };

      try {
        await FirebaseFirestore.instance
            .collection('levels')
            .doc(_selectedLevel)
            .collection('trueOrFalse')
            .doc(exerciseId)
            .update(exerciseData);
        _clearForm();
      } catch (error) {
        // Handle errors here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update true or false exercise: $error')),
        );
      }
    }
  }

  Future<void> _deleteTrueOrFalseExercise(String exerciseId) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete True/False Exercise'),
          content: Text('Are you sure you want to delete this exercise?'),
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
                      .collection('trueOrFalse')
                      .doc(exerciseId)
                      .delete();
                  Navigator.of(context).pop();
                } catch (error) {
                  // Handle error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete exercise: $error')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('True/False Exercises for Level $_selectedLevel'),
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
                  .collection('trueOrFalse')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  final exercises = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return ListTile(
                        title: Text('Exercise ${exercise.id}'),
                        subtitle: Text('Statement: ${exercise['statement']}'),
                        onTap: () {
                          // Show dialog to update true/false exercise
                          _statementController.text = exercise['statement'];
                          _isTrue = exercise['isTrue'];
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Update True/False Exercise'),
                                content: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      TextFormField(
                                        controller: _statementController,
                                        decoration: InputDecoration(labelText: 'Statement'),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a statement';
                                          }
                                          return null;
                                        },
                                      ),
                                      Row(
                                        children: [
                                          Text('Is True: '),
                                          Checkbox(
                                            value: _isTrue,
                                            onChanged: (value) {
                                              setState(() {
                                                _isTrue = value!;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _updateTrueOrFalseExercise(exercise.id);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Update'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteTrueOrFalseExercise(exercise.id);
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
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add True/False Exercise'),
                content: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _statementController,
                        decoration: InputDecoration(labelText: 'Statement'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a statement';
                          }
                          return null;
                        },
                      ),
                      Row(
                        children: [
                          Text('Is True: '),
                          Checkbox(
                            value: _isTrue,
                            onChanged: (value) {
                              setState(() {
                                _isTrue = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _addTrueOrFalseExercise();
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
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
