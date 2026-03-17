import 'package:flutter/material.dart';
import 'screens/profile_screen.dart';
import 'screens/task_list_screen.dart';

void main() {
  runApp(const StudentTaskApp());
}

class StudentTaskApp extends StatelessWidget {
  const StudentTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Profile & Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      // Set ProfileScreen as the initial screen
      home: const ProfileScreen(),
      // Define routes for easy navigation if needed
      routes: {
        '/profile': (context) => const ProfileScreen(),
        '/tasks': (context) => const TaskListScreen(),
      },
    );
  }
}
