import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService with ChangeNotifier {
  static const String _monthlySubscriptionId = 'com.promptnote.monthly_subscription';
  final bool mockMode;
  
  PurchaseService({this.mockMode = false}) {
    if (!mockMode) {
      _initInAppPurchase();
    } else {
      _available = true;
      _products = []; // Mock products could be added here
    }
  }
  
  bool _available = false;
  bool get available => _available;
  
  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  Future<void> _initInAppPurchase() async {
    if (mockMode) return;
    
    _isLoading = true;
    notifyListeners();
    
    final bool available = await InAppPurchase.instance.isAvailable();
    
    if (available) {
      // Set up listener for purchase updates
      final Stream<List<PurchaseDetails>> purchaseUpdated = 
          InAppPurchase.instance.purchaseStream;
      
      purchaseUpdated.listen(_onPurchaseUpdate);
      
      // Load product details
      await _loadProducts();
    }
    
    _available = available;
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> _loadProducts() async {
    Set<String> ids = {_monthlySubscriptionId};
    ProductDetailsResponse response = 
        await InAppPurchase.instance.queryProductDetails(ids);
    
    _products = response.productDetails;
  }
  
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    // Handle purchase updates
  }
  
  Future<void> purchaseSubscription() async {
    // Implement subscription purchase logic
  }
  
  Future<void> restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
  }
} 