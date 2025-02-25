import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:prompt_note_app/models/note_model.dart';

class StorageService with ChangeNotifier {
  static Database? _database;
  final bool mockMode;
  
  // Mock data for development
  final List<NoteModel> _mockNotes = [];
  
  StorageService({this.mockMode = false}) {
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
  
  Future<Database> get database async {
    if (mockMode) throw UnimplementedError('Database not available in mock mode');
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  // Initialize database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'prompt_note.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE notes('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'title TEXT, '
          'content TEXT, '
          'tags TEXT, '
          'last_updated INTEGER, '
          'user_id TEXT, '
          'firebase_id TEXT)'
        );
      },
    );
  }
  
  // Insert note into local database
  Future<int> insertNote(NoteModel note) async {
    try {
      final db = await database;
      int id = await db.insert(
        'notes',
        note.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      notifyListeners();
      return id;
    } catch (e) {
      rethrow;
    }
  }
  
  // Update existing note
  Future<int> updateNote(NoteModel note) async {
    try {
      final db = await database;
      int result = await db.update(
        'notes',
        note.toMap(),
        where: 'id = ?',
        whereArgs: [note.id],
      );
      notifyListeners();
      return result;
    } catch (e) {
      rethrow;
    }
  }
  
  // Delete note
  Future<int> deleteNote(int id) async {
    try {
      final db = await database;
      int result = await db.delete(
        'notes',
        where: 'id = ?',
        whereArgs: [id],
      );
      notifyListeners();
      return result;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get notes (mock implementation)
  Future<List<NoteModel>> getNotes(String userId) async {
    if (mockMode) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return _mockNotes.where((note) => note.userId == userId).toList();
    }
    
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'notes',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'last_updated DESC',
      );
      
      return List.generate(maps.length, (i) {
        return NoteModel.fromMap(maps[i]);
      });
    } catch (e) {
      rethrow;
    }
  }
  
  // Search notes
  Future<List<NoteModel>> searchNotes(String userId, String query) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'notes',
        where: 'user_id = ? AND (title LIKE ? OR content LIKE ? OR tags LIKE ?)',
        whereArgs: [userId, '%$query%', '%$query%', '%$query%'],
        orderBy: 'last_updated DESC',
      );
      
      return List.generate(maps.length, (i) {
        return NoteModel.fromMap(maps[i]);
      });
    } catch (e) {
      rethrow;
    }
  }
} 