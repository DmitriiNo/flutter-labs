import 'package:flutter/material.dart';
import 'note.dart';
import 'repository.dart';

class HomeViewModel with ChangeNotifier {
  final NoteRepository _noteRepository = NoteRepository();
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isSearching = false;

  List<Note> get notes => _isSearching ? _filteredNotes : _notes;
  bool get isSearching => _isSearching;

  Future<void> loadNotes() async {
    try {
      _notes = await _noteRepository.getAllNotes();
    } catch (e) {
    }
    notifyListeners();
  }

  Future<void> addNote(String title, String content, String date) async {
    try {
      await _noteRepository.addNote(Note(
        title: title,
        content: content,
        date: date,
      ));
      await loadNotes();
    } catch (e) {
    }
  }

  // Обновление заметки
  Future<void> updateNote(Note note) async {
    await _noteRepository.updateNote(note);
    await loadNotes(); // Перезагрузка списка
  }

  // Удаление заметки
  Future<void> deleteNote(int id) async {
    await _noteRepository.deleteNote(id);
    await loadNotes(); // Перезагрузка списка
  }

  // Поиск заметок
  void searchNotes(String query) {
    if (query.isEmpty) {
      _isSearching = false;
      _filteredNotes = [];
    } else {
      _isSearching = true;
      _filteredNotes = _notes.where((note) {
        final title = note.title.toLowerCase();
        final content = note.content.toLowerCase();
        final searchQuery = query.toLowerCase();
        return title.contains(searchQuery) || content.contains(searchQuery);
      }).toList();
    }
    notifyListeners();
  }

  // Очистка поиска
  void clearSearch() {
    _isSearching = false;
    _filteredNotes = [];
    notifyListeners();
  }
}