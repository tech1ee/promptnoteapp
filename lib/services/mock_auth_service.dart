import 'package:flutter/material.dart';
import 'package:prompt_note_app/models/user_model.dart';

class MockAuthService with ChangeNotifier {
  UserModel? _mockUserModel;
  
  MockAuthService() {
    _setupMockUser();
  }
  
  void _setupMockUser() {
    // Create a mock user for testing
    _mockUserModel = UserModel(
      uid: 'mock-user-123',
      email: 'test@example.com',
      displayName: 'Test User',
      isPremium: false,
    );
  }
  
  UserModel? get user => _mockUserModel;
  UserModel? get currentUser => _mockUserModel;
  
  Future<void> mockSignIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    _mockUserModel = UserModel(
      uid: 'mock-user-123',
      email: email,
      displayName: email.split('@').first,
      isPremium: false,
    );
    notifyListeners();
  }
  
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    _mockUserModel = null;
    notifyListeners();
  }
  
  Future<void> register(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    _mockUserModel = UserModel(
      uid: 'mock-user-123',
      email: email,
      displayName: email.split('@').first,
      isPremium: false,
    );
    notifyListeners();
  }
  
  Future<void> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    _mockUserModel = UserModel(
      uid: 'mock-user-123',
      email: 'google-user@example.com',
      displayName: 'Google User',
      isPremium: false,
    );
    notifyListeners();
  }
} 