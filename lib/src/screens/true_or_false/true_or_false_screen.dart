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
    try {
      await FirebaseFirestore.instance
          .collection('levels')
          .doc(_selectedLevel)
          .collection('trueOrFalse')
          .doc(exerciseId)
          .delete();
    } catch (error) {
      // Handle errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete true or false exercise: $error')),
      );
    }
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
        onPressed: _addTrueOrFalseExercise,
        child: Icon(Icons.add),
      ),
    );
  }
}
