import 'package:flutter/material.dart';
import 'package:prompt_note_app/models/dataset_model.dart';

class MockStorageService with ChangeNotifier {
  final List<DatasetModel> _mockDatasets = [];
  
  MockStorageService() {
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
  
  Future<int> insertDataset(DatasetModel dataset) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final newId = _mockDatasets.isEmpty ? 1 : (_mockDatasets.map((d) => d.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
    final newDataset = dataset.copyWith(id: newId);
    _mockDatasets.add(newDataset);
    
    notifyListeners();
    return newId;
  }
  
  Future<int> updateDataset(DatasetModel dataset) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _mockDatasets.indexWhere((d) => d.id == dataset.id);
    if (index >= 0) {
      _mockDatasets[index] = dataset;
    }
    
    notifyListeners();
    return 1; // Success
  }
  
  Future<int> deleteDataset(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final index = _mockDatasets.indexWhere((d) => d.id == id);
    if (index >= 0) {
      _mockDatasets.removeAt(index);
    }
    
    notifyListeners();
    return 1; // Success
  }
  
  Future<List<DatasetModel>> getDatasets(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockDatasets.where((dataset) => dataset.userId == userId).toList();
  }
  
  Future<List<DatasetModel>> searchDatasets(String userId, String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final lowercaseQuery = query.toLowerCase();
    return _mockDatasets.where((dataset) => 
      dataset.userId == userId && 
      (dataset.title.toLowerCase().contains(lowercaseQuery) || 
       dataset.content.toLowerCase().contains(lowercaseQuery) ||
       dataset.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)))
    ).toList();
  }
  
  Future<List<DatasetModel>> getAllDatasets() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<DatasetModel>.from(_mockDatasets);
  }
  
  Future<DatasetModel?> getDataset(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockDatasets.firstWhere((dataset) => dataset.id == id);
    } catch (e) {
      return null;
    }
  }
} 