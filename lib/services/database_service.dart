import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:prompt_note_app/models/dataset_model.dart';
import 'package:prompt_note_app/models/user_model.dart';
import 'package:prompt_note_app/services/auth_service.dart';

class DatabaseService with ChangeNotifier {
  final AuthService authService;
  final bool mockMode;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  
  // Mock data for development
  final List<DatasetModel> _mockDatasets = [];
  
  DatabaseService({required this.authService, this.mockMode = false}) {
    if (mockMode) {
      _setupMockData();
    }
  }
  
  void _setupMockData() {
    // Add some sample datasets for testing
    _mockDatasets.addAll([
      DatasetModel(
        id: 1,
        title: 'Welcome to Prompt Datasets',
        content: 'This is a sample dataset to help you get started.',
        lastUpdated: DateTime.now().millisecondsSinceEpoch,
        userId: 'mock-user-123',
        tags: ['welcome', 'getting-started'],
      ),
      DatasetModel(
        id: 2,
        title: 'Ideas for my novel',
        content: 'Main character should have a mysterious background...',
        lastUpdated: DateTime.now().millisecondsSinceEpoch - 86400000, // 1 day ago
        userId: 'mock-user-123',
        tags: ['writing', 'novel'],
      ),
    ]);
  }
  
  // Save dataset (mock implementation)
  Future<String> saveDatasetMock(DatasetModel dataset) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    // If updating existing dataset
    if (dataset.id != null) {
      final index = _mockDatasets.indexWhere((d) => d.id == dataset.id);
      if (index >= 0) {
        _mockDatasets[index] = dataset;
      }
    } else {
      // Create new dataset with mock ID
      final newId = _mockDatasets.isEmpty ? 1 : (_mockDatasets.map((d) => d.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
      final newDataset = dataset.copyWith(
        id: newId,
        firebaseId: 'mock-firebase-id-$newId',
      );
      _mockDatasets.add(newDataset);
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
  
  // Reference to datasets collection
  DatabaseReference get _datasetsRef => _database.ref().child('datasets');
  
  // Reference to current user's datasets
  DatabaseReference get _currentUserDatasetsRef => 
      _datasetsRef.child(authService.currentUser?.uid ?? '');
  
  // Save dataset to Firebase (for premium users)
  Future<String> saveDataset(DatasetModel dataset) async {
    if (mockMode) {
      return saveDatasetMock(dataset);
    }
    
    try {
      DatabaseReference datasetRef;
      
      if (dataset.firebaseId != null) {
        // Update existing dataset
        datasetRef = _currentUserDatasetsRef.child(dataset.firebaseId!);
        await datasetRef.update(dataset.toJson());
      } else {
        // Create new dataset
        datasetRef = _currentUserDatasetsRef.push();
        final firebaseId = datasetRef.key;
        await datasetRef.set(dataset.copyWith(firebaseId: firebaseId).toJson());
      }
      
      notifyListeners();
      return datasetRef.key!;
    } catch (e) {
      rethrow;
    }
  }
  
  // Get mock datasets
  Future<List<DatasetModel>> getMockDatasets() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return _mockDatasets.where((dataset) => dataset.userId == authService.user?.uid).toList();
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
  
  // ... additional methods for handling prompts usage and fetching datasets
} 