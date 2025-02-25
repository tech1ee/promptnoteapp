import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:prompt_note_app/models/note_model.dart';
import 'package:prompt_note_app/models/user_model.dart';
import 'package:prompt_note_app/services/auth_service.dart';

class DatabaseService with ChangeNotifier {
  final AuthService authService;
  final bool mockMode;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  // Mock data for development
  final List<NoteModel> _mockNotes = [];
  
  DatabaseService({required this.authService, this.mockMode = false}) {
    if (mockMode) {
      _setupMockData();
    }
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
  
  // Save note (mock implementation)
  Future<String> saveNoteMock(NoteModel note) async {
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
  
  // Original implementation for Firebase
  // Reference to users collection
  DatabaseReference get _usersRef => _database.ref().child('users');
  
  // Reference to current user's document
  DatabaseReference get _currentUserRef => 
      _usersRef.child(authService.currentUser?.uid ?? '');
  
  // Reference to notes collection
  DatabaseReference get _notesRef => _database.ref().child('notes');
  
  // Reference to current user's notes
  DatabaseReference get _currentUserNotesRef => 
      _notesRef.child(authService.currentUser?.uid ?? '');
  
  // Save note to Firebase (for premium users)
  Future<String> saveNote(NoteModel note) async {
    if (mockMode) {
      return saveNoteMock(note);
    }
    
    try {
      DatabaseReference noteRef;
      
      if (note.firebaseId != null) {
        // Update existing note
        noteRef = _currentUserNotesRef.child(note.firebaseId!);
        await noteRef.update(note.toJson());
      } else {
        // Create new note
        noteRef = _currentUserNotesRef.push();
        final firebaseId = noteRef.key;
        await noteRef.set(note.copyWith(firebaseId: firebaseId).toJson());
      }
      
      notifyListeners();
      return noteRef.key!;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get mock notes
  Future<List<NoteModel>> getMockNotes() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return _mockNotes.where((note) => note.userId == authService.user?.uid).toList();
  }
  
  // Create or update user data
  Future<void> updateUserData(UserModel user) async {
    try {
      await _usersRef.child(user.uid).update(user.toJson());
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      final snapshot = await _usersRef.child(uid).get();
      if (!snapshot.exists) return null;
      
      return UserModel.fromJson(Map<String, dynamic>.from(
          snapshot.value as Map<dynamic, dynamic>));
    } catch (e) {
      rethrow;
    }
  }
  
  // Update user's premium status
  Future<void> updatePremiumStatus(String uid, bool isPremium) async {
    try {
      await _usersRef.child(uid).update({'isPremium': isPremium});
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  // ... additional methods for handling prompts usage and fetching notes
} 