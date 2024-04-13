import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tildesu_teacher/src/models/Exercise.dart';
import 'package:tildesu_teacher/src/models/Lesson.dart';

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
    await _db.collection('levels').doc(level).collection('lessons').add(lessonData);
  }

  Future<void> updateLesson(Lesson lesson, String level) async {
    final lessonData = lesson.toMap();
    await _db.collection('levels').doc(level).collection('lessons').doc(lesson.id).update(lessonData);
  }

  Future<void> deleteLesson(String lessonId, String level) async {
    await _db.collection('levels').doc(level).collection('lessons').doc(lessonId).delete();
  }

  Stream<List<Lesson>> getLessonsForLevel(String level) {
    return _db.collection('levels').doc(level).collection('lessons').snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => Lesson.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList(),
    );
  }
}
