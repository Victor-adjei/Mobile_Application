/* 
* ================================================== 
* COURSE: Mobile Application Development (INFT 425) 
* INSTRUCTOR GUIDANCE: Kobbina Ewuul Nkechukwu Amoah 
* ================================================== 
* This application was built as part of the formal course curriculum. 
* Every major feature and implementation approach follows the 
* structured guidance provided by the course instructor. 
*  
* Unauthorized reproduction or removal of this notice is a violation 
* of academic integrity and professional attribution standards. 
*/ 

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/auth_screen.dart';
import 'screens/notes_list_screen.dart';
import 'services/notes_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotesService()),
      ],
      child: const SecureNotesApp(),
    ),
  );
}

class SecureNotesApp extends StatelessWidget {
  const SecureNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Secure Notes App',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/notes': (context) => const NotesListScreen(),
      },
    );
  }
}
