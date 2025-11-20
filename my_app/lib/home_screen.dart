import 'package:flutter/material.dart';
import 'note_edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Список заметок
  List<Map<String, String>> notes = [];
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredNotes = [];
  bool _isSearching = false;

  void _openNoteEditor(BuildContext context) async {
    // Получение результата из редактора
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(),
      ),
    );

    // Если возврат с данными - добавление заметки
    if (result != null && result is Map) {
      setState(() {
        notes.add({
          'title': result['title'] ?? 'Без названия',
          'content': result['content'] ?? '',
          'preview': _getPreview(result['content'] ?? ''),
          'date': result['date'] ?? _getCurrentDate(),
        });
        // Если активно окно поиска - обновление результатов
        if (_isSearching) {
          _performSearch();
        }
      });
    }
  }

  void _openNoteForEditing(BuildContext context, int index) async {
    final note = _isSearching ? _filteredNotes[index] : notes[index];
    final originalIndex = notes.indexOf(note);
    
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(
          initialTitle: note['title'],
          initialContent: note['content'],
        ),
      ),
    );

    // Обновление заметки если возврат с данными
    if (result != null && result is Map) {
      setState(() {
        notes[originalIndex] = {
          'title': result['title'] ?? 'Без названия',
          'content': result['content'] ?? '',
          'preview': _getPreview(result['content'] ?? ''),
          'date': result['date'] ?? _getCurrentDate(),
        };
        // Если активно окно поиска - обновление результатов
        if (_isSearching) {
          _performSearch();
        }
      });
    }
  }

  // Функция поиска
  void _performSearch() {
    final query = _searchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _filteredNotes = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _filteredNotes = notes.where((note) {
        final title = note['title']?.toLowerCase() ?? '';
        final content = note['content']?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        return title.contains(searchQuery) || content.contains(searchQuery);
      }).toList();
    });
  }

  // Очистка поиска
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _isSearching = false;
      _filteredNotes = [];
    });
  }

  // Создание превью (первые 50 символов)
  String _getPreview(String content) {
    if (content.isEmpty) return 'Нет содержимого';
    if (content.length <= 50) return content;
    return '${content.substring(0, 50)}...';
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}.${now.month}.${now.year}';
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
            child: Row(
              children: [
                // Поле ввода
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск заметок...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onSubmitted: (_) {
                      _performSearch();
                    },
                  ),
                ),
                SizedBox(width: 8),
                // Кнопка поиска
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _performSearch,
                  tooltip: 'Найти заметки',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                // Кнопка очистки
                if (_isSearching)
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: _clearSearch,
                    tooltip: 'Очистить поиск',
                  ),
              ],
            ),
          ),
          
          // Статус поиска
          if (_isSearching)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'Найдено заметок: ${_filteredNotes.length}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: _clearSearch,
                    child: Text('Показать все'),
                  ),
                ],
              ),
            ),
          
          // Список заметок или сообщение о пустоте
          Expanded(
            child: _isSearching 
                ? (_filteredNotes.isEmpty 
                    ? _buildEmptyState(true)
                    : _buildNotesList(_filteredNotes))
                : (notes.isEmpty
                    ? _buildEmptyState(false)
                    : _buildNotesList(notes)),
          ),
        ],
      ),
      
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

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.note_add_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            isSearching 
                ? 'Заметки не найдены'
                : 'У вас пока нет заметок',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            isSearching
                ? 'Попробуйте изменить поисковый запрос'
                : 'Нажмите + чтобы создать первую заметку',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(List<Map<String, String>> notesList) {
    return ListView.builder(
      itemCount: notesList.length,
      itemBuilder: (context, index) {
        final note = notesList[index];
        return _buildNoteItem(
          context: context,
          title: note['title']!,
          preview: note['preview']!,
          date: note['date']!,
          index: index,
          isSearching: _isSearching,
        );
      },
    );
  }

  Widget _buildNoteItem({
    required BuildContext context,
    required String title,
    required String preview,
    required String date,
    required int index,
    required bool isSearching,
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
          _openNoteForEditing(context, index);
        },
        onLongPress: () {
          _showDeleteDialog(context, index, isSearching);
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index, bool isSearching) {
    final note = isSearching ? _filteredNotes[index] : notes[index];
    final originalIndex = notes.indexOf(note);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Удалить заметку?'),
          content: Text('Вы точно хотите удалить "${note['title']}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  notes.removeAt(originalIndex);
                  // Если активно окно поиска - обновление результатов
                  if (isSearching) {
                    _performSearch();
                  }
                });
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