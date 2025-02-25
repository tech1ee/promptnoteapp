import 'package:flutter/material.dart';
import 'package:prompt_note_app/models/note_model.dart';
import 'package:prompt_note_app/models/user_model.dart';

class MockDatabaseService with ChangeNotifier {
  final List<NoteModel> _mockNotes = [];
  
  MockDatabaseService() {
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
  
  Future<String> saveNote(NoteModel note) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    // If updating existing note
    if (note.id != null) {
      final index = _mockNotes.indexWhere((n) => n.id == note.id);
      if (index >= 0) {
        _mockNotes[index] = note;
      }
    } else {
      // Create new note with mock ID
      final newId = _mockNotes.isEmpty ? 1 : (_mockNotes.map((n) => n.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
      final newNote = note.copyWith(
        id: newId,
        firebaseId: 'mock-firebase-id-$newId',
      );
      _mockNotes.add(newNote);
    }
    
    notifyListeners();
    return 'mock-firebase-id';
  }
  
  Future<List<NoteModel>> getNotes(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return _mockNotes.where((note) => note.userId == userId).toList();
  }
  
  Future<void> updateUserData(UserModel user) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock implementation - no actual update needed
    notifyListeners();
  }
  
  Future<UserModel?> getUserData(String uid) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return UserModel(
      uid: uid,
      email: 'test@example.com',
      displayName: 'Test User',
      isPremium: false,
    );
  }
  
  Future<void> updatePremiumStatus(String uid, bool isPremium) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock implementation - no actual update needed
    notifyListeners();
  }
} 