import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PuzzlesScreen extends StatefulWidget {
  @override
  _PuzzlesScreenState createState() => _PuzzlesScreenState();
}

class _PuzzlesScreenState extends State<PuzzlesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sentencePartsController = TextEditingController();
  final _correctOrderController = TextEditingController();

  @override
  void dispose() {
    _sentencePartsController.dispose();
    _correctOrderController.dispose();
    super.dispose();
  }

  void _addPuzzle() async {
    if (_formKey.currentState!.validate()) {
      List<String> sentenceParts = _sentencePartsController.text.split(',');
      List<int> correctOrder = _correctOrderController.text
          .split(',')
          .map((s) => int.tryParse(s.trim())!)
          .toList();

      final exerciseData = {
        'sentenceParts': sentenceParts,
        'correctOrder': correctOrder,
      };

      // Add to Firestore
      FirebaseFirestore.instance.collection('exercises').add(exerciseData).then((result) {
        // Clear the form
        _clearForm();
      }).catchError((error) {
        // Handle errors here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add puzzle: $error')),
        );
      });
    }
  }

  void _clearForm() {
    _sentencePartsController.clear();
    _correctOrderController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Puzzle Exercise'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _sentencePartsController,
                decoration: InputDecoration(labelText: 'Sentence Parts (comma-separated)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter sentence parts';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _correctOrderController,
                decoration: InputDecoration(labelText: 'Correct Order (comma-separated indexes)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the correct order';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _addPuzzle,
                  child: Text('Add Puzzle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
