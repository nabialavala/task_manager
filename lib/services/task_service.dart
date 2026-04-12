import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final CollectionReference _taskCollection =
      FirebaseFirestore.instance.collection('tasks');

  // CREATE
  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;

    await _taskCollection.add({
      'title': title.trim(),
      'isCompleted': false,
      'subtasks': [],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // READ (STREAM)
  Stream<List<Task>> streamTasks() {
    return _taskCollection
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  // UPDATE (toggle complete)
  Future<void> toggleTask(Task task) async {
    await _taskCollection.doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  // DELETE
  Future<void> deleteTask(String taskId) async {
    await _taskCollection.doc(taskId).delete();
  }
}