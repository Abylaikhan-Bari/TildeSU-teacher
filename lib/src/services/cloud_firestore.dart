import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addExercise(Map<String, dynamic> exerciseData) async {
    await _db.collection('exercises').add(exerciseData);
  }
}
