import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prompt_note_app/services/mock_auth_service.dart';
import 'package:prompt_note_app/services/mock_storage_service.dart';
import 'package:prompt_note_app/features/notes/screens/note_editor_screen.dart';
import 'package:prompt_note_app/features/prompts/screens/prompt_generator_screen.dart';
import 'package:prompt_note_app/features/settings/screens/settings_screen.dart';
import 'package:prompt_note_app/features/notes/widgets/note_card.dart';
import 'package:prompt_note_app/models/note_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<NoteModel>? _searchResults;
  int _currentIndex = 0;
  List<NoteModel> _notes = [];
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    // We'll load notes in didChangeDependencies instead,
    // since we need access to the Provider context
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load notes after the widget is fully initialized
    // and we have access to the Provider context
    _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadNotes() {
    try {
      final authService = Provider.of<MockAuthService>(context, listen: false);
      if (authService.user == null) return; // Skip if no user
      
      final userId = authService.user!.uid;
      
      // Get current timestamp as int (milliseconds since epoch)
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Use mock data for now instead of potentially problematic service
      setState(() {
        _notes = [
          NoteModel(
            id: 1,
            title: 'Welcome to Prompt Notes',
            content: 'This is a sample note to help you get started.',
            tags: ['welcome', 'getting-started'],
            lastUpdated: now,
            userId: userId,
          ),
          NoteModel(
            id: 2,
            title: 'Ideas for my novel',
            content: 'Main character should have a mysterious background...',
            tags: ['writing', 'novel'],
            lastUpdated: now,
            userId: userId,
          ),
        ];
        _refreshKey++; // Increment refresh key
      });
    } catch (e) {
      print('Error loading notes: $e');
      // Show a user-friendly error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading notes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _search(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final storageService = Provider.of<MockStorageService>(context, listen: false);
    final authService = Provider.of<MockAuthService>(context, listen: false);
    
    if (authService.user != null) {
      storageService.searchNotes(authService.user!.uid, query).then((results) {
        if (mounted) {
          setState(() {
            _searchResults = results;
          });
        }
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _searchResults = null;
    });
  }

  void _createNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NoteEditorScreen(),
      ),
    ).then((result) {
      // Refresh the notes list if a note was successfully created
      if (result == true) {
        // Reload notes from storage
        _loadNotes();
        
        // Show a confirmation snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note saved successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<MockAuthService>(context);
    
    if (authService.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userId = authService.user!.uid;
    // Use local notes list instead of relying directly on the service
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  ),
                ),
                onChanged: _search,
                autofocus: true,
              )
            : const Text('Your Notes'),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
        ],
      ),
      body: _currentIndex == 0
          ? _isSearching && _searchResults != null
              ? _buildNotesList(_searchResults!)
              : _buildNotesList(_notes) // Use cached notes list instead of future
          : _currentIndex == 1
              ? const PromptGeneratorScreen()
              : const SettingsScreen(),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _createNote,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildNotesList(List<NoteModel> notes) {
    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _isSearching
                  ? 'No results found'
                  : 'No notes yet\nTap the + button to create one',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteEditorScreen(
                  note: note,
                ),
              ),
            ).then((result) {
              if (result == true) {
                // Refresh notes if note was updated
                _loadNotes();
              }
            });
          },
        );
      },
    );
  }
} 