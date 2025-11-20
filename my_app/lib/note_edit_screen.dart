import 'package:flutter/material.dart';

class NoteEditScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialContent;
  
  const NoteEditScreen({
    super.key,
    this.initialTitle,
    this.initialContent,
  });

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _contentController.text = widget.initialContent ?? '';
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    
    if (title.isEmpty && content.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Введите заголовок заметки')),
      );
      return;
    }
    
    // Если оба поля пустые - обычный выход
    if (title.isEmpty && content.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    
    // Возврат данных на предыдущий экран
    Navigator.of(context).pop({
      'title': title,
      'content': content,
      'date': _getCurrentDate(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            _saveNote(); // Автосохранение при нажатии "Назад"
          },
        ),
        title: Text(
          widget.initialTitle == null ? 'Новая заметка' : 'Редактирование',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveNote,
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Поле заголовка
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Заголовок заметки',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
            ),
            
            SizedBox(height: 16),
            
            // Разделительная линия
            Divider(height: 1, color: Colors.grey[300]),
            
            SizedBox(height: 16),
            
            // Поле содержимого
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Содержимое заметки...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                style: TextStyle(fontSize: 16),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
            
            SizedBox(height: 16),
            
            // Дата изменения
            Text(
              'Дата изменения: ${_getCurrentDate()}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}.${now.month}.${now.year}';
  }
}