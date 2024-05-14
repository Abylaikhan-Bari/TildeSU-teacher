import 'package:flutter/material.dart';
import 'package:tildesu_teacher/src/services/firestore_service.dart';
import 'package:tildesu_teacher/src/models/UsefulTip.dart';

class UsefulTipsScreen extends StatefulWidget {
  @override
  _UsefulTipsScreenState createState() => _UsefulTipsScreenState();
}

class _UsefulTipsScreenState extends State<UsefulTipsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _showAddEditTipDialog({UsefulTip? tip}) async {
    if (tip != null) {
      _titleController.text = tip.title;
      _contentController.text = tip.content;
    } else {
      _titleController.clear();
      _contentController.clear();
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tip != null ? 'Edit Tip' : 'Add Tip'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _contentController,
                  decoration: InputDecoration(labelText: 'Content'),
                  maxLines: null,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                final newTip = UsefulTip(
                  id: tip?.id ?? '',
                  title: _titleController.text,
                  content: _contentController.text,
                );
                if (tip != null) {
                  await _firestoreService.updateUsefulTip(newTip);
                } else {
                  await _firestoreService.addUsefulTip(newTip);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTip(String tipId) async {
    await _firestoreService.deleteUsefulTip(tipId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Useful Tips', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF34559C),
      ),
      body: StreamBuilder<List<UsefulTip>>(
        stream: _firestoreService.getUsefulTips(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tips found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final tip = snapshot.data![index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(tip.title),
                  onTap: () => _showAddEditTipDialog(tip: tip),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Tip'),
                            content: Text('Are you sure you want to delete this tip?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Delete'),
                                onPressed: () {
                                  _deleteTip(tip.id);
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditTipDialog(),
        child: Icon(Icons.add),
        backgroundColor: const Color(0xFF34559C),
      ),
    );
  }
}
