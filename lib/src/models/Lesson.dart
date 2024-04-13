class Lesson {
  final String id;
  final String title;
  final String description;
  final String content;

  Lesson({required this.id, required this.title, required this.description, required this.content});

  factory Lesson.fromFirestore(Map<String, dynamic> firestore, String id) {
    return Lesson(
      id: id,
      title: firestore['title'] as String,
      description: firestore['description'] as String,
      content: firestore['content'] as String
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'content': content,
    };
  }
}