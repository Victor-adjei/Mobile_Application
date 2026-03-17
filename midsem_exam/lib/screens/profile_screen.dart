import 'package:flutter/material.dart';
import '../models/student.dart';
import 'task_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Student data as state
  late Student student;

  @override
  void initState() {
    super.initState();
    // Initial data
    student = Student(
      name: 'Victor Adjei Yeboah',
      studentId: '226IT02000269',
      programme: 'IT',
      level: 300,
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: student.name);
    final idController = TextEditingController(text: student.studentId);
    final programmeController = TextEditingController(text: student.programme);
    final levelController = TextEditingController(text: student.level.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(labelText: 'Student ID'),
                ),
                TextField(
                  controller: programmeController,
                  decoration: const InputDecoration(labelText: 'Programme'),
                ),
                TextField(
                  controller: levelController,
                  decoration: const InputDecoration(labelText: 'Level'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  student = Student(
                    name: nameController.text,
                    studentId: idController.text,
                    programme: programmeController.text,
                    level: int.tryParse(levelController.text) ?? student.level,
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blueAccent.withOpacity(0.1),
              child: Text(
                student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.person, 'Name', student.name),
                    const Divider(),
                    _buildInfoRow(Icons.badge, 'ID', student.studentId),
                    const Divider(),
                    _buildInfoRow(Icons.school, 'Programme', student.programme),
                    const Divider(),
                    _buildInfoRow(
                        Icons.trending_up, 'Level', student.level.toString()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showEditProfileDialog,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TaskListScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.task_alt),
                    label: const Text('View Tasks'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
