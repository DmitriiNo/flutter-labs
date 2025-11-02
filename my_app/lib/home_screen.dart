import 'package:flutter/material.dart';
import 'note_edit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openNoteEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(), // Новая заметка
      ),
    );
  }

  void _openNoteForEditing(BuildContext context, String title, String content) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(
          initialTitle: title,
          initialContent: content,
        ), // Редактирование существующей
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyNotes'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Поисковая строка
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Поиск',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          
          // Список заметок
          Expanded(
            child: ListView(
              children: [
                // Заметка 1
                _buildNoteItem(
                  context: context,
                  title: 'Тренировки',
                  preview: 'Понедельник: грудь...',
                  date: '29.10.2025',
                ),
                
                // Заметка 2
                _buildNoteItem(
                  context: context,
                  title: 'Список покупок',
                  preview: 'Молоко, хлеб, яйца...',
                  date: '28.10.2025',
                ),
                
                // Заметка 3
                _buildNoteItem(
                  context: context,
                  title: 'Планы на неделю',
                  preview: 'Понедельник: встреча...',
                  date: '27.10.2025',
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Кнопка добавления заметки
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openNoteEditor(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildNoteItem({
    required BuildContext context,
    required String title,
    required String preview,
    required String date,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.0),
            Text(preview),
            SizedBox(height: 4.0),
            Text(
              date,
              style: TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ],
        ),
        onTap: () {
          _openNoteForEditing(context, title, preview);
        },
        onLongPress: () {
          _showDeleteDialog(context);
        },
      ),
    );
  }

  // Диалоговое окно удаления
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Удалить заметку?'),
          content: Text('Вы точно хотите удалить выбранную заметку?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Реализовать удаление заметки
                Navigator.of(context).pop();
              },
              child: Text(
                'Удалить',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}