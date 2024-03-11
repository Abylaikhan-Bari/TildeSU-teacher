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
            .doc('A1')
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
            .doc('A1')
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
          .doc('A1')
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
        title: Text('Add True/False Exercise'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
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
              SwitchListTile(
                title: const Text('Is True'),
                value: _isTrue,
                onChanged: (bool val) {
                  setState(() {
                    _isTrue = val;
                  });
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _addTrueOrFalseExercise,
                  child: Text('Add Exercise'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
