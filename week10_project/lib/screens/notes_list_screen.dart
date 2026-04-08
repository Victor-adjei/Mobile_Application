import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/notes_service.dart';
import '../models/note.dart';
import 'add_edit_note_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NotesService _notesService = NotesService.instance;
  bool _isLoading = true;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadNotes() async {
    await _notesService.loadNotes();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  String _getCountdownText(DateTime noteDate) {
    final now = DateTime.now();
    final difference = noteDate.difference(now);

    if (difference.isNegative) {
      return "Released ${DateFormat('MMM d').format(noteDate)}";
    }

    if (difference.inDays > 0) {
      return "${difference.inDays}d ${difference.inHours % 24}h remaining";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ${difference.inMinutes % 60}m remaining";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ${difference.inSeconds % 60}s remaining";
    } else {
      return "${difference.inSeconds}s remaining";
    }
  }

  Widget _buildNoteThumbnail(Note note) {
    if (note.imageUrl == null) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.blueAccent.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.security_rounded, color: Colors.blueAccent, size: 28),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: (kIsWeb || note.imageUrl!.startsWith('http'))
          ? CachedNetworkImage(
              imageUrl: note.imageUrl!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade100, child: const Icon(Icons.image, size: 20, color: Colors.grey)),
              errorWidget: (context, url, error) => Container(color: Colors.grey.shade100, child: const Icon(Icons.error, size: 20, color: Colors.red)),
            )
          : Image.file(
              File(note.imageUrl!),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: Colors.grey.shade100, child: const Icon(Icons.broken_image, size: 20, color: Colors.grey)),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(
          'Security Vault',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.blueAccent.shade700),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFF8FAFF),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.blueAccent),
            onPressed: _loadNotes,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.blueAccent),
            onPressed: () => Navigator.pushReplacementNamed(context, '/auth'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : _notesService.notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_reset_rounded, size: 100, color: Colors.grey.shade200),
                      const SizedBox(height: 20),
                      Text(
                        "No secure logs.",
                        style: GoogleFonts.outfit(fontSize: 20, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  itemCount: _notesService.notes.length,
                  itemBuilder: (context, index) {
                    final note = _notesService.notes[index];
                    final isDue = note.noteDate.isBefore(DateTime.now());
                    
                    return FadeInUp(
                      delay: Duration(milliseconds: 50 * index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withValues(alpha: 0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            onTap: () => _editNote(note),
                            onLongPress: () => _deleteNote(note.id),
                            leading: _buildNoteThumbnail(note),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    note.title.isEmpty ? "Secured Entry" : note.title,
                                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueAccent.shade700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (!isDue)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      children: [
                                        Icon(Icons.timer_outlined, size: 12, color: Colors.amber.shade700),
                                        const SizedBox(width: 4),
                                        Text(
                                          "Pending",
                                          style: GoogleFonts.inter(fontSize: 10, color: Colors.amber.shade700, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  note.content.substring(0, note.content.length > 50 ? 50 : note.content.length) + (note.content.length > 50 ? "..." : ""),
                                  style: GoogleFonts.inter(fontSize: 14, color: Colors.blueGrey.shade400),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isDue ? Colors.green.shade50 : Colors.blueAccent.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isDue ? Icons.verified_rounded : Icons.schedule_rounded,
                                            size: 14,
                                            color: isDue ? Colors.green : Colors.blueAccent,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _getCountdownText(note.noteDate),
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: isDue ? Colors.green.shade700 : Colors.blueAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.blueAccent.withValues(alpha: 0.2), size: 16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNote,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        icon: const Icon(Icons.add_moderator_rounded, color: Colors.white),
        label: Text("Secure Log", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _addNote() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditNoteScreen()));
    if (result == true) {
      _loadNotes();
    }
  }

  void _editNote(Note note) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditNoteScreen(note: note)));
    if (result == true) {
      _loadNotes();
    }
  }

  Future<void> _deleteNote(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Encrypted Log', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to permanently delete this record? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('DELETE LOG'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _notesService.deleteNote(id);
      _loadNotes();
    }
  }
}
