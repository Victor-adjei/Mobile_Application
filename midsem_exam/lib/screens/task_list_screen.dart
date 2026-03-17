import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // Hardcoded list of at least 3 tasks as per requirement
  final List<Task> _tasks = [
    Task(
      title: 'Complete Midsem Project',
      courseCode: 'INFT 425',
      dueDate: DateTime(2026, 3, 20),
    ),
    Task(
      title: 'Submit Assignment 2',
      courseCode: 'INFT 401',
      dueDate: DateTime(2026, 3, 25),
      isComplete: true,
    ),
    Task(
      title: 'Study for Finals',
      courseCode: 'GENS 202',
      dueDate: DateTime(2026, 4, 15),
    ),
  ];

  void _addTask(String title, String courseCode, DateTime dueDate) {
    setState(() {
      _tasks.add(Task(
        title: title,
        courseCode: courseCode,
        dueDate: dueDate,
      ));
    });
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final courseController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Task Title'),
                  ),
                  TextField(
                    controller: courseController,
                    decoration: const InputDecoration(labelText: 'Course Code'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(selectedDate == null
                          ? 'No date chosen'
                          : 'Date: ${_formatDate(selectedDate!)}'),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setDialogState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: const Text('Pick Date'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty &&
                        courseController.text.isNotEmpty &&
                        selectedDate != null) {
                      _addTask(
                        titleController.text,
                        courseController.text,
                        selectedDate!,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('No tasks yet!'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: task.isComplete
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Text(
                        '${task.courseCode} • Due: ${_formatDate(task.dueDate)}'),
                    trailing: Checkbox(
                      value: task.isComplete,
                      onChanged: (value) {
                        setState(() {
                          task.isComplete = value!;
                        });
                      },
                      activeColor: Colors.blueAccent,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
