import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:prompt_note_app/models/user_model.dart';

class AuthService with ChangeNotifier {
  final bool mockMode;
  
  // Mock user for development
  User? _mockUser;
  UserModel? _mockUserModel;
  
  AuthService({this.mockMode = false}) {
    if (mockMode) {
      _setupMockUser();
    }
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
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  User? get currentUser => mockMode ? _mockUser : _auth.currentUser;
  UserModel? get user => mockMode ? _mockUserModel : _userFromFirebaseUser(_auth.currentUser);
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    if (mockMode) {
      // For mock mode, just pretend we signed in successfully
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      notifyListeners();
      throw UnimplementedError('Mock mode enabled - no actual authentication');
    }
    
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      notifyListeners();
      return result;
    } catch (e) {
      rethrow;
    }
  }
  
  // Mock sign in without actually using Firebase
  Future<void> mockSignIn(String email, String password) async {
    if (!mockMode) return;
    
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    _mockUserModel = UserModel(
      uid: 'mock-user-123',
      email: email,
      displayName: email.split('@').first,
      isPremium: false,
    );
    notifyListeners();
  }
  
  // Sign out
  Future<void> signOut() async {
    if (mockMode) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      _mockUserModel = null;
      notifyListeners();
      return;
    }
    
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      notifyListeners();
      return result;
    } catch (e) {
      rethrow;
    }
  }
  
  // Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      UserCredential result = await _auth.signInWithCredential(credential);
      notifyListeners();
      return result;
    } catch (e) {
      rethrow;
    }
  }
  
  // Convert Firebase User to UserModel
  UserModel? _userFromFirebaseUser(User? user) {
    if (user == null) return null;
    
    return UserModel(
      uid: user.uid,
      email: user.email!,
      displayName: user.displayName,
    );
  }
} 