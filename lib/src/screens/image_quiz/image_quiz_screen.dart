import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageQuizzesScreen extends StatefulWidget {
  @override
  _ImageQuizzesScreenState createState() => _ImageQuizzesScreenState();
}

class _ImageQuizzesScreenState extends State<ImageQuizzesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(4, (index) => TextEditingController());
  int _correctOptionIndex = 0;
  String _selectedLevel = 'A1';

  @override
  void dispose() {
    _questionController.dispose();
    _imageUrlController.dispose();
    _optionControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _addOrUpdateQuiz({String? quizId}) async {
    if (_formKey.currentState!.validate()) {
      final quizData = {
        'imageQuestion': _questionController.text.trim(),
        'imageOptions': _optionControllers.map((controller) => controller.text.trim()).toList(),
        'correctImageOptionIndex': _correctOptionIndex,
        'imageUrl': _imageUrlController.text.trim(),
      };

      final collectionReference = FirebaseFirestore.instance
          .collection('levels')
          .doc(_selectedLevel)
          .collection('imageQuizzes');

      if (quizId == null) {
        // Adding a new quiz
        await collectionReference.add(quizData);
      } else {
        // Updating an existing quiz
        await collectionReference.doc(quizId).update(quizData);
      }

      _clearForm();
    }
  }

  void _clearForm() {
    _questionController.clear();
    _imageUrlController.clear();
    _optionControllers.forEach((controller) => controller.clear());
    setState(() {
      _correctOptionIndex = 0;
    });
  }

  Future<void> _deleteImageQuiz(String quizId) async {
    await FirebaseFirestore.instance
        .collection('levels')
        .doc(_selectedLevel)
        .collection('imageQuizzes')
        .doc(quizId)
        .delete();
  }

  String _translate(String key) {
    // Add your translation logic here. For now, we'll just return the key.
    return key;
  }

  Widget _buildForm({required bool isUpdating, String? quizId}) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
      child: Column(
      mainAxisSize: MainAxisSize.min,
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
          controller: _imageUrlController,
          decoration: InputDecoration(labelText: _translate('Image URL')),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return _translate('Please enter an image URL');
            }
            return null;
          },
        ),
        ...List.generate(_optionControllers.length, (index) {
          return TextFormField(
            controller: _optionControllers[index],
            decoration: InputDecoration(labelText: _translate('Option ${index + 1}')),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return _translate('Please enter option ${index + 1}');
              }
              return null;
            },
          );
        }),
        DropdownButtonFormField<int>(
          value: _correctOptionIndex,
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _correctOptionIndex = newValue;
              });
            }
          },
          items: List.generate(_optionControllers.length, (index) {
            return DropdownMenuItem<int>(
              value: index,
              child: Text(_translate('Option ${index + 1}')),
            );
          }),
          decoration: InputDecoration(labelText: _translate('Correct Option Index')),
          validator: (value) {
            if (value == null) {
              return _translate('Please select the correct option index');
            }
            return null;
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(_translate('Cancel')),
            ),
            TextButton(
              onPressed: () {
                _addOrUpdateQuiz(quizId: isUpdating ? quizId : null);
                Navigator.of(context).pop();
              },
              child: Text(isUpdating ? _translate('Update') : _translate('Add')),
            ),
          ],
        ),
      ],
    ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_translate('Image Quizzes for Level') + ' $_selectedLevel'),
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
                  .collection('imageQuizzes')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text(_translate('No image quizzes found')));
                }
                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> quiz = document.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(quiz['imageQuestion'] ?? ''),
                      subtitle: Text(quiz['imageOptions'][quiz['correctImageOptionIndex']].toString()),
                      onTap: () {
                        // Fill in the controllers with the current quiz info
                        _questionController.text = quiz['imageQuestion'];
                        _imageUrlController.text = quiz['imageUrl'];
                        _optionControllers.asMap().forEach((index, controller) {
                          controller.text = quiz['imageOptions'][index];
                        });
                        _correctOptionIndex = quiz['correctImageOptionIndex'];
                        // Show the update dialog
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(_translate('Update Image Quiz')),
                              content: _buildForm(isUpdating: true, quizId: document.id),
                            );
                          },
                        );
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteImageQuiz(document.id),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _clearForm();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(_translate('Add Image Quiz')),
                content: _buildForm(isUpdating: false),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
