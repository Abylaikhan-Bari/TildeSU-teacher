class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime time;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'time': time.toIso8601String(),
    };
  }

  static ChatMessage fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['senderId'],
      text: json['text'],
      time: DateTime.parse(json['time']),
    );
  }
}
