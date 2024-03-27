import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DictionaryCardsScreen extends StatefulWidget {
  @override
  _DictionaryCardsScreenState createState() => _DictionaryCardsScreenState();
}

class _DictionaryCardsScreenState extends State<DictionaryCardsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _englishWordController = TextEditingController();
  final _kazakhWordController = TextEditingController();
  final _russianWordController = TextEditingController();
  String _selectedLevel = 'A1'; // Default selected level

  @override
  void dispose() {
    _englishWordController.dispose();
    _kazakhWordController.dispose();
    _russianWordController.dispose();
    super.dispose();
  }

  void _addOrUpdateDictionaryCard({String? cardId}) async {
    if (_formKey.currentState!.validate()) {
      final cardData = {
        'wordEnglish': _englishWordController.text.trim(),
        'wordKazakh': _kazakhWordController.text.trim(),
        'wordRussian': _russianWordController.text.trim(),
      };

      final collectionReference = FirebaseFirestore.instance
          .collection('levels')
          .doc(_selectedLevel)
          .collection('dictionaryCards');

      if (cardId == null) {
        // Adding a new card
        await collectionReference.add(cardData);
      } else {
        // Updating an existing card
        await collectionReference.doc(cardId).update(cardData);
      }

      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dictionary card ${cardId == null ? "added" : "updated"} successfully')),
      );
    }
  }

  void _clearForm() {
    _englishWordController.clear();
    _kazakhWordController.clear();
    _russianWordController.clear();
  }

  Future<void> _deleteDictionaryCard(String cardId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Dictionary Card'),
          content: Text('Are you sure you want to delete this card?'),
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

    if (shouldDelete == true) {
      await FirebaseFirestore.instance
          .collection('levels')
          .doc(_selectedLevel)
          .collection('dictionaryCards')
          .doc(cardId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dictionary card deleted successfully')),
      );
    }
  }

  Widget _buildForm({required bool isUpdating, String? cardId}) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _englishWordController,
            decoration: InputDecoration(labelText: 'English Word'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the English word';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _kazakhWordController,
            decoration: InputDecoration(labelText: 'Kazakh Word'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the Kazakh word';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _russianWordController,
            decoration: InputDecoration(labelText: 'Russian Word'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the Russian word';
              }
              return null;
            },
          ),
          TextButton(
            onPressed: () => _addOrUpdateDictionaryCard(cardId: isUpdating ? cardId : null),
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
        title: Text('Dictionary Cards for Level $_selectedLevel'),
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
              .collection('dictionaryCards')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No dictionary cards found'));
            }
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> card = document.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(card['wordEnglish'] ?? ''),
                  subtitle: Text('Kazakh: ${card['wordKazakh']} | Russian: ${card['wordRussian']}'),
                  onTap: () {
                    _englishWordController.text = card['wordEnglish'];
                    _kazakhWordController.text = card['wordKazakh'];
                    _russianWordController.text = card['wordRussian'];
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Update Dictionary Card'),
                          content: _buildForm(isUpdating: true, cardId: document.id),
                        );
                      },
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteDictionaryCard(document.id),
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
                title: Text('Add Dictionary Card'),
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

