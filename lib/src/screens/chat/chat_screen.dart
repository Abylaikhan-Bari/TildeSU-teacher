import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tildesu_teacher/src/screens/chat/individual_chat_screen.dart';
import 'package:tildesu_teacher/src/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tildesu_teacher/src/services/auth_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('User Messages'),
        backgroundColor: Color(0xFF34559C),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getDistinctUsersWithMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No messages'));
          }
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot doc = snapshot.data!.docs[index];
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
                String senderEmail = data['senderEmail'] as String? ?? 'Unknown';

                return ListTile(
                  title: Text(senderEmail),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => IndividualChatScreen(
                              chatId: doc.id,
                              userEmail: senderEmail
                          )
                      )
                  ),
                );
              }
          );
        },
      ),
    );
  }
}
