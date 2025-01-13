import 'package:flutter/material.dart';
import '../models/cart_item.dart'; // Import the CartItem model

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];

  // Getter to access the cart items
  List<CartItem> get cartItems => _cartItems;

  // Method to add an item to the cart
  void addToCart(CartItem item) {
    _cartItems.add(item);
    notifyListeners();  // Notify listeners to rebuild UI
  }

  // Method to remove an item from the cart
  void removeCartItem(CartItem item) {
    _cartItems.remove(item);
    notifyListeners();
  }

  // Method to place an order (this can be customized to your needs)
  void placeOrder() {
    // Logic to place an order, e.g., sending data to the server
    _cartItems.clear();  // Clear the cart after order is placed
    notifyListeners();
  }
}
