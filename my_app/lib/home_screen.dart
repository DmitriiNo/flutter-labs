import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_view_model.dart';
import 'note_edit_screen.dart';
import 'quote_service.dart';
import 'note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeViewModel>(context, listen: false).loadNotes();
    });
  }

  void _openNoteEditor(BuildContext context) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(),
      ),
    );

    if (result != null && result is Map) {
      final viewModel = Provider.of<HomeViewModel>(context, listen: false);
      await viewModel.addNote(
        result['title'] ?? 'Без названия',
        result['content'] ?? '',
        result['date'] ?? _getCurrentDate(),
      );
    }
  }

  void _openNoteForEditing(BuildContext context, Note note) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditScreen(
          initialTitle: note.title,
          initialContent: note.content,
        ),
      ),
    );

    if (result != null && result is Map) {
      final viewModel = Provider.of<HomeViewModel>(context, listen: false);
      final updatedNote = Note(
        id: note.id,
        title: result['title'] ?? 'Без названия',
        content: result['content'] ?? '',
        date: result['date'] ?? _getCurrentDate(),
      );
      await viewModel.updateNote(updatedNote);
    }
  }

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
    final viewModel = Provider.of<HomeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('MyNotes'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: FutureBuilder<String>(
              future: QuoteService().getDailyQuote(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Загружаем вдохновение...',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ],
                  );
                }
                return Text(
                  snapshot.data ?? 'Начните день с улыбки!',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.blue[800],
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
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
                      viewModel.searchNotes(_searchController.text);
                    },
                  ),
                ),
                SizedBox(width: 8),
                // Кнопка поиска
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    viewModel.searchNotes(_searchController.text);
                  },
                  tooltip: 'Найти заметки',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                // Кнопка очистки
                if (viewModel.isSearching)
                  IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      viewModel.clearSearch();
                    },
                    tooltip: 'Очистить поиск',
                  ),
              ],
            ),
          ),
          
          // Статус поиска
          if (viewModel.isSearching)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'Найдено заметок: ${viewModel.notes.length}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      _searchController.clear();
                      viewModel.clearSearch();
                    },
                    child: Text('Показать все'),
                  ),
                ],
              ),
            ),
          
          // Список заметок или сообщение о пустоте
          Expanded(
            child: viewModel.notes.isEmpty
                ? _buildEmptyState(viewModel.isSearching)
                : _buildNotesList(viewModel.notes, context),
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

  Widget _buildNotesList(List<Note> notesList, BuildContext context) {
    return ListView.builder(
      itemCount: notesList.length,
      itemBuilder: (context, index) {
        final note = notesList[index];
        return _buildNoteItem(
          note: note,
          context: context,
        );
      },
    );
  }

  Widget _buildNoteItem({
    required Note note,
    required BuildContext context,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ListTile(
        title: Text(
          note.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.0),
            Text(_getPreview(note.content)),
            SizedBox(height: 4.0),
            Text(
              note.date,
              style: TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ],
        ),
        onTap: () {
          _openNoteForEditing(context, note);
        },
        onLongPress: () {
          _showDeleteDialog(context, note);
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Удалить заметку?'),
          content: Text('Вы точно хотите удалить "${note.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () async {
                final viewModel = Provider.of<HomeViewModel>(context, listen: false);
                if (note.id != null) {
                  await viewModel.deleteNote(note.id!);
                }
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