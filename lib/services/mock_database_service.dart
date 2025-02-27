import 'package:flutter/material.dart';
import 'package:prompt_note_app/models/dataset_model.dart';
import 'package:prompt_note_app/models/user_model.dart';

class MockDatabaseService with ChangeNotifier {
  final List<DatasetModel> _mockDatasets = [];
  
  MockDatabaseService() {
    _setupMockData();
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
  
  Future<String> saveDataset(DatasetModel dataset) async {
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
  
  Future<List<DatasetModel>> getDatasets(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return _mockDatasets.where((dataset) => dataset.userId == userId).toList();
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