import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class IndividualChatScreen extends StatefulWidget {
  final String chatId;
  final String userEmail;

  IndividualChatScreen({required this.chatId, required this.userEmail});

  @override
  _IndividualChatScreenState createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String chatName = "Chat"; // Default chat name

  @override
  void initState() {
    super.initState();
    _getChatDetails();
  }

  void _getChatDetails() async {
    DocumentSnapshot chatDoc =
    await _firestore.collection('chats').doc(widget.chatId).get();
    setState(() {
      chatName = chatDoc['senderEmail'] ?? "Chat"; // Set chat name from Firestore
    });
  }

  void sendMessage() {
    final text = _controller.text;
    if (text.isNotEmpty) {
      final message = {
        'senderId': 'admin',
        'senderEmail': 'Admin',
        'message': text,
        'timestamp': Timestamp.now(),
      };

      _firestore.collection('chats').doc(widget.chatId).update({
        'messages': FieldValue.arrayUnion([message])
      });
      _controller.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You need to type a message to send it.')),
      );
    }
  }

  Widget _buildMessageItem(Map<String, dynamic> data) {
    String messageText = data['message'] ?? 'No message';
    String senderEmail = data['senderEmail'] == 'Admin' ? 'Admin' : data['senderEmail'] ?? 'Unknown sender';
    bool isMe = data['senderId'] == 'admin';
    DateTime timestamp = (data['timestamp'] as Timestamp).toDate();

    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: isMe ? Colors.green[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(senderEmail, style: TextStyle(fontWeight: FontWeight.bold)),
                Text(messageText),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 2.0,
              bottom: 4.0,
              left: isMe ? 0 : 8.0,
              right: isMe ? 8.0 : 0,
            ),
            child: Text(
              timestamp.toLocal().toString(),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chatName),
        backgroundColor: Color(0xFF34559C),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('chats').doc(widget.chatId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                if (snapshot.data == null || snapshot.data!.data() == null) {
                  return Center(child: Text('No messages'));
                }
                var messages = List<Map<String, dynamic>>.from(snapshot.data!['messages']);
                return ListView.builder(
                  itemCount: messages.length,
                  reverse: true,
                  itemBuilder: (context, index) => _buildMessageItem(messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Send a message...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
