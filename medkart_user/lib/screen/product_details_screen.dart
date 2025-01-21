import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'loginscreen.dart'; // Import your login screen

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  ProductDetailsScreen({required this.product});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int selectedQuantity = 1;
  bool isLoading = false;
  String errorMessage = '';
  bool isLoggedIn = false; // Track login status

  // Quantity selection options (for example, 1 to 10)
  List<int> quantities = List.generate(10, (index) => index + 1);

  // Check login status
  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }



  Future<void> _addToCart() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final token = await _getToken();
    if (token == null) {
      setState(() {
        errorMessage = 'No token found. Please log in.';
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('http://localhost:5000/cart');

    try {
      // Send request to check if the product already exists in the cart
      final checkResponse = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (checkResponse.statusCode == 200) {
        final cartData = json.decode(checkResponse.body);
        bool productInCart = cartData.any((item) => item['product_id'] == widget.product['id']);

        if (productInCart) {
          // Product exists in cart, update quantity
          final updateResponse = await http.put(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'product_id': widget.product['id'],
              'quantity': selectedQuantity,
            }),
          );

          if (updateResponse.statusCode == 200) {
            final responseData = json.decode(updateResponse.body);
            if (responseData['message'].contains('updated')) {
              setState(() {
                isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cart updated: ${widget.product['name']}')),
              );
            }
          } else {
            setState(() {
              errorMessage = 'Failed to update product quantity in cart.';
              isLoading = false;
            });
          }
        } else {
          // Product doesn't exist in cart, add to cart
          final addResponse = await http.post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'product_id': widget.product['id'],
              'quantity': selectedQuantity,
            }),
          );

          if (addResponse.statusCode == 200 || addResponse.statusCode == 201) {
            final responseData = json.decode(addResponse.body);
            if (responseData['message'] == 'Product added to cart') {
              setState(() {
                isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Product added to cart: ${widget.product['name']}')),
              );
            } else {
              setState(() {
                errorMessage = 'Failed to add product to cart.';
                isLoading = false;
              });
            }
          }
        }
      } else {
        setState(() {
          errorMessage = 'Failed to fetch cart data.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Something went wrong. Please try again.';
        isLoading = false;
      });
    }
  }






  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check login status when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['name']),
        backgroundColor: Colors.teal
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.product['image_url'] != null
                ? Image.network(
              widget.product['image_url'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Image.asset(
              'assets/mm6.png',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side: Name and WS Code
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product['name'],
                      style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'WS Code: ${widget.product['ws_code']}',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'MRP: ',
                            style: TextStyle(
                              color: Colors.grey[800], // Darker color for the label
                              fontWeight: FontWeight.bold, // Bold text for emphasis
                              fontSize: 12.0,
                            ),
                          ),
                          TextSpan(
                            text: '${widget.product['sales_price']} ₹',
                            style: TextStyle(
                              color: Colors.teal, // Green color for the price
                              fontWeight: FontWeight.bold, // Bold text for price
                              fontSize: 25.0, // Slightly larger font for better visibility
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Right side: Quantity Dropdown and Add to Cart Button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    DropdownButton<int>(
                      value: selectedQuantity, // Default value
                      icon: Icon(Icons.arrow_downward),
                      elevation: 16,
                      style: TextStyle(color: Colors.black),
                      underline: Container(
                        height: 2,
                        color: Colors.teal
                      ),
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedQuantity = newValue!;
                        });
                      },
                      items: quantities
                          .map<DropdownMenuItem<int>>(
                            (int value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value'),
                        ),
                      )
                          .toList(),
                    ),
                    SizedBox(height: 10.0),
                    ElevatedButton(
                      onPressed: isLoggedIn ? _addToCart : () {
                        // Show Login Screen if not logged in
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Loginscreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                        backgroundColor: Colors.teal,
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        isLoggedIn ? 'Add to Cart' : 'Login to Buy',
                        style: TextStyle(fontSize: 14.0, color: Colors.white),
                      ),
                    ),
                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text(
              widget.product['description'] ??
                  'This medicine is designed to help you maintain your health and well-being. Formulated with high-quality ingredients, it provides effective relief and support for your specific medical needs. Please consult your healthcare professional before using this product to ensure it is suitable for you.',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
