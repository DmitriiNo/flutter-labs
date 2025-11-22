import 'database.dart';
import 'note.dart';

class NoteRepository {
  final DatabaseService _databaseService = DatabaseService();

  Future<int> addNote(Note note) async {
    try {
      final id = await _databaseService.insertNote(note);
      return id;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Note>> getAllNotes() async {
    try {
      final notes = await _databaseService.getNotes();
      return notes;
    } catch (e) {
      return [];
    }
  }

  // Обновление заметки
  Future<int> updateNote(Note note) async {
    return await _databaseService.updateNote(note);
  }

  // Удаление заметки
  Future<int> deleteNote(int id) async {
    return await _databaseService.deleteNote(id);
  }
}