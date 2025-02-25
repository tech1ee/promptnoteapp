import 'package:flutter/material.dart';

class MockPurchaseService with ChangeNotifier {
  bool _available = true;
  bool get available => _available;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  Future<void> purchaseSubscription() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> restorePurchases() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    _isLoading = false;
    notifyListeners();
  }
} 