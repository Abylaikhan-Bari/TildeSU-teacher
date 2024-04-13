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
  List<TextEditingController> _optionControllers = List.generate(4, (index) => TextEditingController());
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
        await collectionReference.add(quizData);
      } else {
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
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Quiz'),
          content: Text('Are you sure you want to delete this image quiz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete ?? false) {
      try {
        await FirebaseFirestore.instance
            .collection('levels')
            .doc(_selectedLevel)
            .collection('imageQuizzes')
            .doc(quizId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image quiz deleted successfully')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete image quiz: $error')),
        );
      }
    }
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
              decoration: InputDecoration(labelText: 'Question'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a question';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an image URL';
                }
                return null;
              },
            ),
            ...List.generate(_optionControllers.length, (index) {
              return TextFormField(
                controller: _optionControllers[index],
                decoration: InputDecoration(labelText: 'Option ${index + 1}'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter option ${index + 1}';
                  }
                  return null;
                },
              );
            }),
            DropdownButtonFormField<int>(
              value: _correctOptionIndex,
              onChanged: (newValue) {
                setState(() {
                  _correctOptionIndex = newValue!;
                });
              },
              items: List.generate(4, (index) {
                return DropdownMenuItem<int>(
                  value: index,
                  child: Text('Option ${index + 1}'),
                );
              }),
              decoration: InputDecoration(labelText: 'Correct Option Index'),
              validator: (value) {
                if (value == null) {
                  return 'Please select the correct option index';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () => _addOrUpdateQuiz(quizId: isUpdating ? quizId : null),
              child: Text(isUpdating ? 'Update' : 'Add'),
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
        title: Text('Image Quizzes for Level $_selectedLevel'),
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
                  .collection('imageQuizzes')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No image quizzes found'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var quiz = snapshot.data!.docs[index];
                    return Card(
                      child: ListTile(
                        title: Text(quiz['imageQuestion']),
                        subtitle: Text('Correct Answer: ' + quiz['imageOptions'][quiz['correctImageOptionIndex']]),
                        onTap: () {
                          _questionController.text = quiz['imageQuestion'];
                          _imageUrlController.text = quiz['imageUrl'];
                          _optionControllers.asMap().forEach((index, controller) {
                            controller.text = quiz['imageOptions'][index];
                          });
                          _correctOptionIndex = quiz['correctImageOptionIndex'];
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Update Image Quiz'),
                                content: _buildForm(isUpdating: true, quizId: quiz.id),
                              );
                            },
                          );
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteImageQuiz(quiz.id),
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
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add Image Quiz'),
                content: _buildForm(isUpdating: false),
              );
            },
          );
        },
        child: Icon(Icons.add),
        backgroundColor: const Color(0xFF34559C),
      ),
    );
  }
}
