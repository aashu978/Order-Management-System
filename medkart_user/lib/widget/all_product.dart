import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../screen/loginScreen.dart';
import '../screen/product_details_screen.dart';

class AllProduct extends StatefulWidget {
  @override
  _AllProductState createState() => _AllProductState();
}

class _AllProductState extends State<AllProduct> {
  List<dynamic> _products = [];
  List<dynamic> _suggestions = [];
  bool _isLoading = false;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
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

        // Update suggestions
        _updateSearchSuggestions(searchQuery);
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

  // Update search suggestions based on the input query
  void _updateSearchSuggestions(String? query) {
    if (query == null || query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _suggestions = _products
          .where((product) =>
          product['name'].toLowerCase().contains(query.toLowerCase()))
          .take(5) // Limit to 5 suggestions
          .toList();
    });
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Products'),
        backgroundColor: Colors.teal,
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
          // Suggestions list
          if (_searchController.text.isNotEmpty && _suggestions.isNotEmpty)
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    title: Text(suggestion['name']),
                    onTap: () {
                      _searchController.text = suggestion['name'];
                      _fetchProducts(searchQuery: suggestion['name']);
                    },
                  );
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

                return GestureDetector(
                  onTap: () {
                    // When tapped, navigate to the ProductDetailsScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          product: product,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          Container(
                            width: 120.0,
                            height: 120.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              image: DecorationImage(
                                image: imageUrl != null
                                    ? NetworkImage(imageUrl)
                                    : AssetImage('assets/mm5.png') as ImageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.0), // Space between image and details

                          // Product Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  'WS Code: ${product['ws_code']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12.0,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'MRP: ',
                                              style: TextStyle(
                                                color: Colors.grey[800],
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.0,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '${product['sales_price']} ₹',
                                              style: TextStyle(
                                                color: Colors.teal,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Add to Cart Button
                          ElevatedButton(
                            onPressed: () {
                              if (_isLoggedIn) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Select the quantity to proceed item to Cart'),
                                  ),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailsScreen(
                                      product: product,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Loginscreen(),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                              backgroundColor: _isLoggedIn ? Colors.teal : Colors.teal,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _isLoggedIn ? 'Add to Cart' : 'Login to Buy',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
    );
  }
}
