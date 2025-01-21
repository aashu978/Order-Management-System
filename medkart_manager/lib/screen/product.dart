import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medkart_manager/screen/uploadScreen.dart';
import '../utils/addProduct.dart';
import '../utils/editProduct.dart';
import 'add_admin.dart';
import 'orderScreen.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> _products = [];
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts({String? searchQuery, int page = 1}) async {
    setState(() {
      _isLoading = true;
      _currentPage = page;
    });

    try {
      final url = Uri.parse(
          'http://localhost:5000/products?search=${searchQuery ?? ''}&limit=8&offset=${(page - 1) * 8}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> productsWithImages = [];

        for (var product in data['products']) {
          final wsCode = product['ws_code'];
          final imageResponse = await http.get(
            Uri.parse('http://localhost:5000/images/ws_code/$wsCode'),
          );

          if (imageResponse.statusCode == 200) {
            final imageData = json.decode(imageResponse.body);
            productsWithImages.add({
              ...Map<String, dynamic>.from(product),
              'image_url': imageData.isNotEmpty ? imageData[0]['url'] : null,
            });
          } else {
            productsWithImages.add({
              ...Map<String, dynamic>.from(product),
              'image_url': null,
            });
          }
        }

        setState(() {
          _products = productsWithImages;
          _isLoading = false;
          _totalPages = data['pages'];
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to load products')));
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Something went wrong')));
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _nextPage() {
    if (_currentPage < _totalPages) {
      _fetchProducts(page: _currentPage + 1);
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      _fetchProducts(page: _currentPage - 1);
    }
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        onProductAdded: _fetchProducts,
      ),
    );
  }

  void _showEditProductDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => EditProductDialog(
        product: product,
        onProductUpdated: _fetchProducts,
      ),
    );
  }

  Future<void> _deleteProduct(int id) async {
    final url = Uri.parse('http://localhost:5000/products/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Product deleted successfully')));
        _fetchProducts();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to delete product')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Something went wrong')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Products'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddAdminPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Products',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _fetchProducts(searchQuery: value);
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                final imageUrl = product['image_url'];

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(8.0),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey.shade200,
                      ),
                      child: imageUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Icon(Icons.image, color: Colors.grey),
                    ),
                    title: Text(
                      product['name'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: \$${product['sales_price']}'),
                        Text('WS Code: ${product['ws_code']}'),
                        Text('Category: ${product['category']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.file_upload_outlined),
                          onPressed: () {
                            // Navigate to the UploadImageScreen and pass the product details
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UploadImageScreen(product: product),
                              ),
                            );
                          },
                          color: Colors.green,
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showEditProductDialog(product),
                          color: Colors.blue,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteProduct(product['id']),
                          color: Colors.red,
                        ),
                      ],
                    ),
                    onTap: () => _showEditProductDialog(product),
                  ),
                );
              },
            ),
          ),
          if (_totalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: _currentPage > 1 ? _previousPage : null,
                  ),
                  SizedBox(width: 8), // Add some spacing between the back arrow and the text
                  Text('Page $_currentPage of $_totalPages'),
                  SizedBox(width: 8), // Add some spacing between the text and the forward arrow
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: _currentPage < _totalPages ? _nextPage : null,
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProductDialog,
        icon: Icon(Icons.add),
        label: Text('Add Product'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}