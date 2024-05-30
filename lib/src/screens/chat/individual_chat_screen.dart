import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tildesu_teacher/src/services/firestore_service.dart';

class IndividualChatScreen extends StatelessWidget {
  final String chatId;
  final String userEmail;

  IndividualChatScreen({required this.chatId, required this.userEmail});

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $userEmail'),
        backgroundColor: Color(0xFF34559C),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('chats').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Something went wrong: ${snapshot.error}');
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Text("No messages available");
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = snapshot.data!.docs[index];
                    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

                    if (data == null) {
                      return ListTile(title: Text('Document data is not available'));
                    }

                    // Safely extracting fields with type checking
                    String message = '';
                    String senderEmail = '';
                    if (data['message'] != null) {
                      message = data['message'] is String ? data['message'] : 'Invalid data type for message';
                    } else {
                      message = 'No message';
                    }
                    if (data['senderEmail'] != null) {
                      senderEmail = data['senderEmail'] is String ? data['senderEmail'] : 'Invalid data type for email';
                    } else {
                      senderEmail = 'Unknown sender';
                    }

                    return ListTile(
                      title: Text(message),
                      subtitle: Text(senderEmail),
                    );
                  },
                );
              },
            )
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    if (_messageController.text.isNotEmpty) {
                      final message = {
                        'senderId': FirebaseAuth.instance.currentUser!.uid,
                        'senderEmail': FirebaseAuth.instance.currentUser!.email,
                        'message': _messageController.text,
                        'timestamp': Timestamp.now(),
                      };
                      await firestoreService.sendMessage(chatId, message);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
