import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EditProductDialog extends StatelessWidget {
  final Map<String, dynamic> product;
  final Function onProductUpdated;

  EditProductDialog({required this.product, required this.onProductUpdated});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController =
    TextEditingController(text: product['name']);
    final TextEditingController wsCodeController =
    TextEditingController(text: product['ws_code'].toString());
    final TextEditingController salesPriceController =
    TextEditingController(text: product['sales_price'].toString());
    final TextEditingController mrpController =
    TextEditingController(text: product['mrp'].toString());
    final TextEditingController packageSizeController =
    TextEditingController(text: product['package_size'].toString());
    final TextEditingController categoryController =
    TextEditingController(text: product['category']);
    final TextEditingController tagsController = TextEditingController(
      text: (product['tags'] != null && product['tags'] is List)
          ? (product['tags'] as List).join(', ')
          : '',
    );

    Future<void> _updateProduct(Map<String, dynamic> updatedProduct) async {
      final url = Uri.parse('http://localhost:5000/products/${product['id']}');
      try {
        final response = await http.put(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(updatedProduct),
        );
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Product updated successfully')));
          onProductUpdated(); // Trigger a refresh of the product list
          Navigator.pop(context);
        } else {
          print('Error response: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update product')));
        }
      } catch (e) {
        print('Exception: $e');
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Something went wrong')));
      }
    }

    return AlertDialog(
      title: Text('Edit Product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product name is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: wsCodeController,
                decoration: InputDecoration(labelText: 'WS Code'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      int.tryParse(value) == null ||
                      int.parse(value) < 0) {
                    return 'WS Code must be a non-negative number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: salesPriceController,
                decoration: InputDecoration(labelText: 'Sales Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Sales Price must be greater than 0';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: mrpController,
                decoration: InputDecoration(labelText: 'MRP'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'MRP must be greater than 0';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: packageSizeController,
                decoration: InputDecoration(labelText: 'Package Size'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      int.tryParse(value) == null ||
                      int.parse(value) <= 0) {
                    return 'Package Size must be greater than 0';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: tagsController,
                decoration: InputDecoration(labelText: 'Tags (comma-separated)'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'At least one tag is required';
                  }
                  final tags = value.split(',').map((tag) => tag.trim());
                  if (tags.any((tag) => tag.isEmpty)) {
                    return 'Tags must not be empty';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog without saving
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              final updatedProduct = {
                'name': nameController.text,
                'ws_code': int.parse(wsCodeController.text),
                'sales_price': double.parse(salesPriceController.text),
                'mrp': double.parse(mrpController.text),
                'package_size': int.parse(packageSizeController.text),
                'category': categoryController.text,
                'tags': tagsController.text
                    .split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList(),
              };
              _updateProduct(updatedProduct);
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}