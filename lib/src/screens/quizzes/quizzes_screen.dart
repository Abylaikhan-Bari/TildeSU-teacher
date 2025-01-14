import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizzesScreen extends StatefulWidget {
  @override
  _QuizzesScreenState createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  List<TextEditingController> _optionControllers = List.generate(4, (index) => TextEditingController());
  int _correctOptionIndex = 0;
  String _selectedLevel = 'A1';

  @override
  void initState() {
    super.initState();
    _optionControllers = List.generate(4, (index) => TextEditingController());
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _addOrUpdateQuiz({String? quizId}) async {
    if (_formKey.currentState!.validate()) {
      List<String> options = _optionControllers.map((controller) => controller.text.trim()).toList();
      final quizData = {
        'question': _questionController.text.trim(),
        'options': options,
        'correctOptionIndex': _correctOptionIndex,
        'correctAnswer': options[_correctOptionIndex],
      };

      final collectionReference = FirebaseFirestore.instance
          .collection('levels')
          .doc(_selectedLevel)
          .collection('quizzes');

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
    _optionControllers.forEach((controller) => controller.clear());
    setState(() {
      _correctOptionIndex = 0;
    });
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('levels')
                    .doc(_selectedLevel)
                    .collection('quizzes')
                    .doc(quizId)
                    .delete();
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _translate(String key) {
    // Replace this function with your translation logic or remove it if not needed.
    return key;
  }

  Widget _buildQuizForm({bool isUpdating = false, String? quizId, Map<String, dynamic>? quizData}) {
    if (quizData != null) {
      _questionController.text = quizData['question'];
      _correctOptionIndex = quizData['correctOptionIndex'];
      quizData['options'].asMap().forEach((index, option) {
        _optionControllers[index].text = option;
      });
    }

    return Form(
      key: _formKey,
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
          ...List.generate(4, (index) {
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
              if (newValue != null) {
                setState(() {
                  _correctOptionIndex = newValue;
                });
              }
            },
            items: List.generate(4, (index) {
              return DropdownMenuItem<int>(
                value: index,
                child: Text('Option ${index + 1}'),
              );
            }),
            decoration: InputDecoration(labelText: 'Correct Option'),
            validator: (value) {
              if (value == null) {
                return 'Please select the correct option';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () => _addOrUpdateQuiz(quizId: quizId),
            child: Text(isUpdating ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_translate('Quizzes for Level') + ' $_selectedLevel'),
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
                  .collection('quizzes')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No quizzes found'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final quiz = snapshot.data!.docs[index];
                    final quizData = quiz.data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text(quizData['question']),
                        subtitle: Text('Correct Answer: ${quizData['options'][quizData['correctOptionIndex']]}'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Update Quiz'),
                                content: _buildQuizForm(isUpdating: true, quizId: quiz.id, quizData: quizData),
                              );
                            },
                          );
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteQuiz(quiz.id),
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
                title: Text('Add Quiz'),
                content: _buildQuizForm(),
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
