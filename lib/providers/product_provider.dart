import 'package:flutter/material.dart';
import '../models/product.dart'; // Adjust the import based on your file structure

class ProductProvider with ChangeNotifier {
  List<Product> _products = [
    Product(
      id: '1',
      name: 'Product 1',
      description: 'Description for Product 1',
      price: 29.99,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    Product(
      id: '2',
      name: 'Product 2',
      description: 'Description for Product 2',
      price: 19.99,
      imageUrl: 'https://via.placeholder.com/150',
    ),
    // Add more products here...
  ];

  List<Product> get products {
    return [..._products]; // Return a copy of the list to prevent direct modifications
  }

  void addProduct(Product product) {
    _products.add(product);
    notifyListeners(); // Notify listeners when the product list changes
  }
}
