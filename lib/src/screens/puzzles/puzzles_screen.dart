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
  TextEditingController _correctOrderController = TextEditingController();

  @override
  void dispose() {
    _sentencePartsController.dispose();
    _correctOrderController.dispose();
    super.dispose();
  }

  Future<void> _addPuzzle() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Puzzle Details'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
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
                    // Generate a unique puzzle ID
                    final puzzleCount = await FirebaseFirestore.instance
                        .collection('levels')
                        .doc(_selectedLevel)
                        .collection('puzzles')
                        .get()
                        .then((value) => value.docs.length);

                    final puzzleId = 'puzzleId${puzzleCount + 1}';

                    await FirebaseFirestore.instance
                        .collection('levels')
                        .doc(_selectedLevel)
                        .collection('puzzles')
                        .doc(puzzleId)
                        .set(exerciseData);

                    _clearForm();
                    Navigator.of(context).pop();
                  } catch (error) {
                    // Handle errors here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add puzzle: $error')),
                    );
                  }
                }
              },
              child: Text('Add Puzzle'),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    _sentencePartsController.clear();
    _correctOrderController.clear();
  }

  Future<void> _updatePuzzle(String puzzleId, List<String> sentenceParts, List<int> correctOrder) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Puzzle'),
          content: Text('Are you sure you want to update this puzzle?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                try {
                  // Perform update operation here
                  // Example:
                  // await FirebaseFirestore.instance
                  //     .collection('levels')
                  //     .doc(_selectedLevel)
                  //     .collection('puzzles')
                  //     .doc(puzzleId)
                  //     .update({
                  //   'sentenceParts': sentenceParts,
                  //   'correctOrder': correctOrder,
                  // });
                  Navigator.of(context).pop();
                } catch (error) {
                  // Handle error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update puzzle: $error')),
                  );
                }
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePuzzle(String puzzleId) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Puzzle'),
          content: Text('Are you sure you want to delete this puzzle?'),
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
                    SnackBar(content: Text('Failed to delete puzzle: $error')),
                  );
                }
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
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

  void _showDetailsDialog(String puzzleId, List<String> sentenceParts, List<int> correctOrder) {
    _sentencePartsController.text = sentenceParts.join(',');
    _correctOrderController.text = correctOrder.join(',');

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
              _updatePuzzle(puzzleId, sentenceParts, correctOrder);
              Navigator.of(context).pop();
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }
}
