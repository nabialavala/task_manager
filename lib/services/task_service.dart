import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final CollectionReference _taskCollection =
      FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;

    await _taskCollection.add({
      'title': title.trim(),
      'isCompleted': false,
      'subtasks': [],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Stream<List<Task>> streamTasks() {
    return _taskCollection.orderBy('createdAt').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  Future<void> toggleTask(Task task) async {
    await _taskCollection.doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _taskCollection.doc(taskId).delete();
  }

  Future<void> addSubtask(Task task, String subtaskTitle) async {
    if (subtaskTitle.trim().isEmpty) return;

    final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks);
    updatedSubtasks.add({
      'title': subtaskTitle.trim(),
      'isCompleted': false,
    });

    await _taskCollection.doc(task.id).update({
      'subtasks': updatedSubtasks,
    });
  }

  Future<void> deleteSubtask(Task task, int subtaskIndex) async {
    final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks);

    if (subtaskIndex < 0 || subtaskIndex >= updatedSubtasks.length) return;

    updatedSubtasks.removeAt(subtaskIndex);

    await _taskCollection.doc(task.id).update({
      'subtasks': updatedSubtasks,
    });
  }

  Future<void> toggleSubtask(Task task, int subtaskIndex) async {
    final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks);

    if (subtaskIndex < 0 || subtaskIndex >= updatedSubtasks.length) return;

    final currentSubtask = Map<String, dynamic>.from(updatedSubtasks[subtaskIndex]);

    currentSubtask['isCompleted'] = !(currentSubtask['isCompleted'] ?? false);
    updatedSubtasks[subtaskIndex] = currentSubtask;

    await _taskCollection.doc(task.id).update({
      'subtasks': updatedSubtasks,
    });
  }
}