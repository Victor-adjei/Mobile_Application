import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../utils/encryption_helper.dart';
import 'secure_storage_service.dart';

class NotesService with ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = true;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final encryptedJson = await SecureStorageService.loadNotes();
      if (encryptedJson == null) {
        _notes = [];
      } else {
        final decryptedJson = EncryptionHelper.decrypt(encryptedJson);
        if (decryptedJson.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(decryptedJson);
          _notes = decoded.map((item) => Note.fromJson(item)).toList();
          _notes.sort((a, b) => b.lastEdited.compareTo(a.lastEdited)); // Newest first
        }
      }
    } catch (e) {
      debugPrint("Error loading notes: $e");
      _notes = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveNotes() async {
    final jsonString = jsonEncode(_notes.map((n) => n.toJson()).toList());
    final encrypted = EncryptionHelper.encrypt(jsonString);
    await SecureStorageService.saveNotes(encrypted);
  }

  Future<void> addNote(Note note) async {
    _notes.insert(0, note);
    await _saveNotes();
    notifyListeners();
  }

  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      await _saveNotes();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _saveNotes();
    notifyListeners();
  }

  // Fallback for UI that doesn't use Provider notification
  static final NotesService instance = NotesService();
}
