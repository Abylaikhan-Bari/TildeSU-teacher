import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PuzzlesScreen extends StatefulWidget {
  @override
  _PuzzlesScreenState createState() => _PuzzlesScreenState();
}

class _PuzzlesScreenState extends State<PuzzlesScreen> {
  String _selectedLevel = 'A1'; // Default selected level
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

      try {
        await FirebaseFirestore.instance
            .collection('levels')
            .doc(_selectedLevel)
            .collection('puzzles')
            .add(exerciseData);
        _clearForm();
      } catch (error) {
        // Handle errors here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add puzzle: $error')),
        );
      }
    }
  }

  void _clearForm() {
    _sentencePartsController.clear();
    _correctOrderController.clear();
  }

  Future<void> _updatePuzzle(String puzzleId) async {
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

      try {
        await FirebaseFirestore.instance
            .collection('levels')
            .doc(_selectedLevel)
            .collection('puzzles')
            .doc(puzzleId)
            .update(exerciseData);
        _clearForm();
      } catch (error) {
        // Handle errors here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update puzzle: $error')),
        );
      }
    }
  }

  Future<void> _deletePuzzle(String puzzleId) async {
    try {
      await FirebaseFirestore.instance
          .collection('levels')
          .doc(_selectedLevel)
          .collection('puzzles')
          .doc(puzzleId)
          .delete();
    } catch (error) {
      // Handle errors here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete puzzle: $error')),
      );
    }
  }

  void _showDetailsDialog(String puzzleId, List<String> sentenceParts, List<int> correctOrder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Puzzle Details'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _sentencePartsController,
                decoration: InputDecoration(labelText: 'Sentence Parts (comma-separated)'),
                initialValue: sentenceParts.join(','),
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
                initialValue: correctOrder.join(','),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the correct order';
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
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _updatePuzzle(puzzleId);
              Navigator.of(context).pop();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Puzzles for Level $_selectedLevel'),
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
                  .collection('puzzles')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  final puzzles = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: puzzles.length,
                    itemBuilder: (context, index) {
                      final puzzle = puzzles[index];
                      final puzzleId = puzzle.id;
                      final sentenceParts = (puzzle['sentenceParts'] as List).cast<String>();
                      final correctOrder = (puzzle['correctOrder'] as List).cast<int>();
                      return ListTile(
                        title: Text('Puzzle $puzzleId'),
                        onTap: () {
                          _showDetailsDialog(puzzleId, sentenceParts, correctOrder);
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deletePuzzle(puzzleId);
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
        onPressed: _addPuzzle,
        child: Icon(Icons.add),
      ),
    );
  }
}
