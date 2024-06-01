import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime time;
  final String? imageUrl; // Add this line

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.time,
    this.imageUrl, // Add this line
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'time': time.toIso8601String(),
      'imageUrl': imageUrl, // Add this line
    };
  }

  static ChatMessage fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      text: json['text'],
      time: DateTime.parse(json['time']),
      imageUrl: json['imageUrl'], // Add this line
    );
  }
}