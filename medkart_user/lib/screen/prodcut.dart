import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medkart_user/screen/orderScreen.dart';
import 'package:medkart_user/screen/product_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/all_product.dart';
import '../widget/footer.dart';
import '../widget/top_offer_carousel.dart';
import 'cartScreen.dart';
import 'loginScreen.dart';

class ProdcutScreen extends StatefulWidget {
  @override
  _ProdcutScreenState createState() => _ProdcutScreenState();
}

class _ProdcutScreenState extends State<ProdcutScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  bool _isLoggedIn = false; // Track login status
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();  // Fetch products without a search query initially
    _checkLoginStatus();
  }

  Future<void> _fetchProducts({String searchQuery = ''}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = 'http://localhost:5000/products?search=$searchQuery'; // Pass search query to API
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> productsWithImages = [];

        for (var product in data['products']) {
          final imageResponse = await http.get(
            Uri.parse('http://localhost:5000/images/ws_code/${product['ws_code']}'),
          );

          if (imageResponse.statusCode == 200) {
            final imageData = json.decode(imageResponse.body);
            productsWithImages.add({
              ...product,
              'image_url': imageData.isNotEmpty ? imageData[0]['url'] : null,
            });
          } else {
            productsWithImages.add({
              ...product,
              'image_url': null,
            });
          }
        }

        setState(() {
          _products = productsWithImages;
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToProductDetails(Map<String, dynamic> product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(product: product),
      ),
    );
  }

  void _loginUser() async {
    setState(() {
      _isLoggedIn = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  void _logoutUser() async {
    setState(() {
      _isLoggedIn = false;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
  }

  // Check the login status when the screen loads
  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products.where((product) {
      final nameMatch = product['name']
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final wsCodeMatch = product['ws_code']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      return nameMatch || wsCodeMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        toolbarHeight: 80,
        titleSpacing: 10,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProdcutScreen(),
                  ),
                );
              },
              child: Row(
                children: [
                  Image.asset(
                    'assets/mm.jpg',
                    height: 50,
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
            SizedBox(width: 10),
            // Search bar inside AppBar with a Flexible widget
            Flexible(
              child: Container(
                height: 40,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Products',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _fetchProducts(searchQuery: value);  // Fetch products on search
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          _isLoggedIn
              ? Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen()),
                  );
                },
                icon: Icon(Icons.shopping_cart, color: Colors.white),
                label: Text(
                  'Cart',
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrderScreen()),
                  );
                },
                icon: Icon(Icons.list_alt, color: Colors.white),
                label: Text(
                  'Orders',
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                ),
              ),
              TextButton.icon(
                onPressed: _logoutUser,
                icon: Icon(Icons.logout, color: Colors.white),
                label: Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                ),
              ),
            ],
          )
              : TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Loginscreen(
                    onLogin: _loginUser, // Pass the callback
                  ),
                ),
              );
            },
            icon: Icon(Icons.login, color: Colors.white),
            label: Text(
              'Log In',
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis, // Prevent overflow
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
              children: [
                TopOfferCarousel(),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Top Trending Product",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to AllProduct page
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AllProduct()), // Replace with your actual AllProduct page widget
                          );
                        },
                        child: Text("View All"),
                      )
                    ],
                  ),
                ),

                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = (constraints.maxWidth ~/ 150)
                        .clamp(2, 5);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 1.6,
                      ),
                      padding: const EdgeInsets.all(8.0),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return GestureDetector(
                          onTap: () => _navigateToProductDetails(product),
                          child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: SingleChildScrollView( // Wrap with SingleChildScrollView
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 120.0,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
                                      image: DecorationImage(
                                        image: product['image_url'] != null
                                            ? NetworkImage(product['image_url'])
                                            : AssetImage('assets/mm5.png') as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
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
                                                      builder: (context) => ProductDetailsScreen(product: product),
                                                    ),
                                                  );
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => Loginscreen()),
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
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                Footer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
