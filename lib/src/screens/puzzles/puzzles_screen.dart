import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PuzzlesScreen extends StatefulWidget {
  @override
  _PuzzlesScreenState createState() => _PuzzlesScreenState();
}

class _PuzzlesScreenState extends State<PuzzlesScreen> {
  String _selectedLevel = 'A1'; // Default selected level
  final _formKey = GlobalKey<FormState>();
  TextEditingController _sentencePartsController = TextEditingController();

  @override
  void dispose() {
    _sentencePartsController.dispose();
    super.dispose();
  }


  Future<void> _addOrUpdatePuzzle({String? puzzleId}) async {
    final isUpdate = puzzleId != null;
    final dialogTitle = isUpdate ? 'Update Puzzle' : 'Add Puzzle';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$dialogTitle Details'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _sentencePartsController,
              decoration: InputDecoration(labelText: _translate('Sentence Parts (comma-separated)')),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return _translate('Please enter sentence parts');
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(_translate('Cancel')),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final sentenceParts = _sentencePartsController.text.split(',').map((e) => e.trim()).toList();
                  final correctOrder = List.generate(sentenceParts.length, (index) => index);
                  final exerciseData = {
                    'sentenceParts': sentenceParts,
                    'correctOrder': correctOrder,
                  };

                  if (!isUpdate) {
                    // Find the next available puzzle ID
                    final snapshot = await FirebaseFirestore.instance
                        .collection('levels')
                        .doc(_selectedLevel)
                        .collection('puzzles')
                        .orderBy(FieldPath.documentId)
                        .get();

                    int maxId = 0;
                    snapshot.docs.forEach((doc) {
                      final docId = doc.id;
                      if (docId.startsWith('puzzleId')) {
                        final currentId = int.tryParse(docId.replaceFirst('puzzleId', ''));
                        if (currentId != null) {
                          maxId = max(maxId, currentId);
                        }
                      }
                    });

                    final nextPuzzleId = 'puzzleId${maxId + 1}';

                    // Add a new puzzle with the calculated ID
                    await FirebaseFirestore.instance
                        .collection('levels')
                        .doc(_selectedLevel)
                        .collection('puzzles')
                        .doc(nextPuzzleId)
                        .set(exerciseData);
                  } else {
                    // Update an existing puzzle
                    await FirebaseFirestore.instance
                        .collection('levels')
                        .doc(_selectedLevel)
                        .collection('puzzles')
                        .doc(puzzleId)
                        .update(exerciseData);
                  }

                  _clearForm();
                  Navigator.of(context).pop();
                }
              },
              child: Text(isUpdate ? _translate('Update') : _translate('Add')),
            ),
          ],
        );
      },
    );
  }




  void _clearForm() {
    _sentencePartsController.clear();
  }

  Future<void> _deletePuzzle(String puzzleId) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_translate('Delete Puzzle')),
          content: Text(_translate('Are you sure you want to delete this puzzle?')),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('levels')
                      .doc(_selectedLevel)
                      .collection('puzzles')
                      .doc(puzzleId)
                      .delete();
                  Navigator.of(context).pop();
                } catch (error) {
                  // Handle error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_translate('Failed to delete puzzle: $error'))),
                  );
                }
              },
              child: Text(_translate('Yes')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(_translate('No')),
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
        title: Text(_translate('Puzzles for Level $_selectedLevel')),

      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: _selectedLevel,
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('levels')
                  .doc(_selectedLevel)
                  .collection('puzzles')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final puzzles = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: puzzles.length,
                  itemBuilder: (context, index) {
                    final puzzle = puzzles[index];
                    final puzzleId = puzzle.id;
                    final sentenceParts = (puzzle['sentenceParts'] as List).cast<String>();
                    // 'correctOrder' is now automatically managed, no need for manual input
                    return Card(
                      child: ListTile(
                        title: Text(_translate('Puzzle $puzzleId')),
                        onTap: () {
                          _sentencePartsController.text = sentenceParts.join(', ');
                          _addOrUpdatePuzzle(puzzleId: puzzleId);
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deletePuzzle(puzzleId),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _clearForm();
          _addOrUpdatePuzzle();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  String _translate(String text) {
    // Here you can implement your translation logic
    // For now, let's just return the input text
    return text;
  }
}
