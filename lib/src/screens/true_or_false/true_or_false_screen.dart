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

  void _addOrUpdateTrueOrFalse({String? docId}) async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'statement': _statementController.text.trim(),
        'isTrue': _isTrue,
      };

      CollectionReference collection = FirebaseFirestore.instance
          .collection('levels')
          .doc(_selectedLevel)
          .collection('trueOrFalse');

      if (docId == null) {
        await collection.add(data);
      } else {
        await collection.doc(docId).update(data);
      }

      _clearForm();
    }
  }

  void _clearForm() {
    _statementController.clear();
    setState(() {
      _isTrue = true;
    });
  }

  Future<void> _deleteTrueOrFalse(String docId) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete True/False'),
          content: Text('Are you sure you want to delete this item?'),
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
                    .collection('trueOrFalse')
                    .doc(docId)
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

  Widget _trueOrFalseForm({bool isUpdating = false, String? docId, Map<String, dynamic>? data}) {
    if (data != null) {
      _statementController.text = data['statement'];
      _isTrue = data['isTrue'];
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _statementController,
            decoration: InputDecoration(labelText: 'Statement'),
            validator: (value) => value!.isEmpty ? 'Please enter a statement' : null,
          ),
          SwitchListTile(
            title: Text('Is True'),
            value: _isTrue,
            onChanged: (bool value) {
              setState(() {
                _isTrue = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: () => _addOrUpdateTrueOrFalse(docId: docId),
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
                  .collection('trueOrFalse')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No true/false exercises found'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final docData = doc.data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text(docData['statement']),
                        subtitle: Text(docData['isTrue'] ? 'True' : 'False'),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Edit True/False Exercise'),
                                content: _trueOrFalseForm(
                                  isUpdating: true,
                                  docId: doc.id,
                                  data: docData,
                                ),
                              );
                            },
                          );
                        },
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteTrueOrFalse(doc.id),
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
                title: Text('Add True/False Exercise'),
                content: _trueOrFalseForm(),
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
