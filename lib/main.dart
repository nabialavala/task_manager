import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'models/task.dart';
import 'services/task_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TaskService _taskService = TaskService();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final title = _taskController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task title cannot be empty')),
      );
      return;
    }

    await _taskService.addTask(title);
    _taskController.clear();
  }

  Future<void> _showAddSubtaskDialog(Task task) async {
    final subtaskController = TextEditingController();

    final subtaskTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Subtask'),
          content: TextField(
            controller: subtaskController,
            decoration: const InputDecoration(
              hintText: 'Enter subtask title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, subtaskController.text.trim());
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    subtaskController.dispose();

    if (subtaskTitle != null && subtaskTitle.isNotEmpty) {
      await _taskService.addSubtask(task, subtaskTitle);
    }
  }

  Future<void> _confirmDelete(String taskId) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await _taskService.deleteTask(taskId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a new task',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _taskService.streamTasks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final tasks = snapshot.data ?? [];

                if (tasks.isEmpty) {
                  return const Center(
                    child: Text('No tasks yet. Add one above!'),
                  );
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ExpansionTile(
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: (_) async {
                            await _taskService.toggleTask(task);
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _confirmDelete(task.id),
                        ),
                        children: [
                          if (task.subtasks.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text('No subtasks yet'),
                            )
                          else
                            ...List.generate(task.subtasks.length, (subtaskIndex) {
                              final subtask = task.subtasks[subtaskIndex];
                              final isSubtaskCompleted =
                                  subtask['isCompleted'] ?? false;

                              return ListTile(
                                leading: Checkbox(
                                  value: isSubtaskCompleted,
                                  onChanged: (_) async {
                                    await _taskService.toggleSubtask(
                                      task,
                                      subtaskIndex,
                                    );
                                  },
                                ),
                                title: Text(
                                  subtask['title'] ?? '',
                                  style: TextStyle(
                                    decoration: isSubtaskCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    await _taskService.deleteSubtask(
                                      task,
                                      subtaskIndex,
                                    );
                                  },
                                ),
                              );
                            }),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              bottom: 12,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => _showAddSubtaskDialog(task),
                                icon: const Icon(Icons.add),
                                label: const Text('Add Subtask'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}