// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:tildesu_teacher/src/models/ChatMessage.dart';
//
// class ChatService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Stream<List<ChatMessage>> getMessages() {
//     return _firestore.collection('chats')
//         .orderBy('time', descending: true)
//         .snapshots()
//         .map((snapshot) =>
//         snapshot.docs.map((doc) => ChatMessage.fromJson(doc.data() as Map<String, dynamic>)).toList());
//   }
//
//   Future<void> sendMessage(ChatMessage message) {
//     return _firestore.collection('chats').add(message.toJson());
//   }
// }
