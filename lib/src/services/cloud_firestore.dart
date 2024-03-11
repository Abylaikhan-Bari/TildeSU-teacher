import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tildesu_teacher/src/models/Exercise.dart';

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
}
