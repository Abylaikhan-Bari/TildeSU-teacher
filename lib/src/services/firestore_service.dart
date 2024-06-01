import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tildesu_teacher/src/models/Exercise.dart';
import 'package:tildesu_teacher/src/models/Lesson.dart';
import 'package:tildesu_teacher/src/models/UsefulTip.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addExercise(Exercise exercise) async {
    final exerciseData = exercise.toMap();
    await _db.collection('exercises').add(exerciseData);
  }

  Future<void> updateExercise(Exercise exercise) async {
    final exerciseData = exercise.toMap();
    await _db.collection('exercises').doc(exercise.id).update(exerciseData);
  }

  Future<void> deleteExercise(String exerciseId) async {
    await _db.collection('exercises').doc(exerciseId).delete();
  }

  Stream<List<Exercise>> getExercises() {
    return _db.collection('exercises').snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => Exercise.fromFirestore(doc.data(), doc.id))
          .toList(),
    );
  }

  Future<void> addLesson(Lesson lesson, String level) async {
    final lessonData = lesson.toMap();
    await _db
        .collection('levels')
        .doc(level)
        .collection('lessons')
        .add(lessonData);
  }

  Future<void> updateLesson(Lesson lesson, String level) async {
    final lessonData = lesson.toMap();
    await _db
        .collection('levels')
        .doc(level)
        .collection('lessons')
        .doc(lesson.id)
        .update(lessonData);
  }

  Future<void> deleteLesson(String lessonId, String level) async {
    await _db
        .collection('levels')
        .doc(level)
        .collection('lessons')
        .doc(lessonId)
        .delete();
  }

  Stream<List<Lesson>> getLessonsForLevel(String level) {
    return _db
        .collection('levels')
        .doc(level)
        .collection('lessons')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => Lesson.fromFirestore(
          doc.data() as Map<String, dynamic>, doc.id))
          .toList(),
    );
  }

  Future<void> addUsefulTip(UsefulTip tip) async {
    final tipData = tip.toMap();
    await _db.collection('usefulTips').add(tipData);
  }

  Future<void> updateUsefulTip(UsefulTip tip) async {
    final tipData = tip.toMap();
    await _db.collection('usefulTips').doc(tip.id).update(tipData);
  }

  Future<void> deleteUsefulTip(String tipId) async {
    await _db.collection('usefulTips').doc(tipId).delete();
  }

  Stream<List<UsefulTip>> getUsefulTips() {
    return _db.collection('usefulTips').snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => UsefulTip.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList(),
    );
  }

  // Chat-related methods
  Future<void> sendMessage(String chatId, Map<String, dynamic> messageData) async {
    await _db.collection('chats').doc(chatId).update({
      'messages': FieldValue.arrayUnion([messageData])
    });
  }

  Stream<DocumentSnapshot> getMessagesForChat(String chatId) {
    return _db.collection('chats').doc(chatId).snapshots();
  }

  Stream<QuerySnapshot> getDistinctUsersWithMessages() {
    return _db.collection('chats').snapshots();
  }
}
