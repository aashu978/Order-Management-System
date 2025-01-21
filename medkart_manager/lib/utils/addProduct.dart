import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddProductDialog extends StatelessWidget {
  final Function onProductAdded;

  AddProductDialog({required this.onProductAdded});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController wsCodeController = TextEditingController();
    final TextEditingController salesPriceController = TextEditingController();
    final TextEditingController mrpController = TextEditingController();
    final TextEditingController packageSizeController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController tagsController = TextEditingController();

    Future<void> _addNewProduct(Map<String, dynamic> newProduct) async {
      final url = Uri.parse('http://localhost:5000/products');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(newProduct),
        );
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Product added successfully')));
          onProductAdded(); // Trigger a refresh of the product list
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to add product')));
        }
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Something went wrong')));
      }
    }

    return AlertDialog(
      title: Text('Add New Product'),
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
                  if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) < 0) {
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
                  if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
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
                  if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
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
                  if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
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
              final newProduct = {
                'name': nameController.text,
                'ws_code': int.parse(wsCodeController.text),
                'sales_price': double.parse(salesPriceController.text),
                'mrp': double.parse(mrpController.text),
                'package_size': int.parse(packageSizeController.text),
                'category': categoryController.text,
                'tags': tagsController.text.split(',').map((tag) => tag.trim()).toList(),
              };
              _addNewProduct(newProduct);
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}