class UsefulTip {
  String id;
  String title;
  String content;

  UsefulTip({
    required this.id,
    required this.title,
    required this.content,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
    };
  }

  factory UsefulTip.fromFirestore(Map<String, dynamic> data, String id) {
    return UsefulTip(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
    );
  }
}
