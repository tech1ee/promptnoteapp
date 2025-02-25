import 'package:flutter/material.dart';
import 'package:prompt_note_app/models/note_model.dart';

class MockStorageService with ChangeNotifier {
  final List<NoteModel> _mockNotes = [];
  
  MockStorageService() {
    _setupMockData();
  }
  
  void _setupMockData() {
    // Add some sample notes for testing
    _mockNotes.addAll([
      NoteModel(
        id: 1,
        title: 'Welcome to Prompt Notes',
        content: 'This is a sample note to help you get started.',
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
        userId: 'mock-user-123',
        tags: ['welcome', 'getting-started'],
      ),
      NoteModel(
        id: 2,
        title: 'Ideas for my novel',
        content: 'Main character should have a mysterious background...',
        lastUpdated: DateTime.now().millisecondsSinceEpoch - 86400000, // 1 day ago
        userId: 'mock-user-123',
        tags: ['writing', 'novel'],
      ),
    ]);
  }
  
  Future<int> insertNote(NoteModel note) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final newId = _mockNotes.isEmpty ? 1 : (_mockNotes.map((n) => n.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
    final newNote = note.copyWith(id: newId);
    _mockNotes.add(newNote);
    
    notifyListeners();
    return newId;
  }
  
  Future<int> updateNote(NoteModel note) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _mockNotes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _mockNotes[index] = note;
    }
    
    notifyListeners();
    return 1; // Success
  }
  
  Future<int> deleteNote(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _mockNotes.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _mockNotes.removeAt(index);
    }
    
    notifyListeners();
    return 1; // Success
  }
  
  Future<List<NoteModel>> getNotes(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockNotes.where((note) => note.userId == userId).toList();
  }
  
  Future<List<NoteModel>> searchNotes(String userId, String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final lowercaseQuery = query.toLowerCase();
    return _mockNotes.where((note) => 
      note.userId == userId && 
      (note.title.toLowerCase().contains(lowercaseQuery) || 
       note.content.toLowerCase().contains(lowercaseQuery) ||
       note.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)))
    ).toList();
  }
} 