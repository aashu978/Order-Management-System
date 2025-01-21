import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medkart_user/screen/prodcut.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isLoading = true;
  String errorMessage = '';
  List<dynamic> cartItems = [];

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }


  Future<void> _fetchCartItems() async {
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
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<dynamic> itemsWithImages = [];

        for (var cartItem in responseData) {
          final wsCode = cartItem['Product']['ws_code'];
          final imageResponse = await http.get(
            Uri.parse('http://localhost:5000/images/ws_code/$wsCode'),
          );

          if (imageResponse.statusCode == 200) {
            final imageData = json.decode(imageResponse.body);
            itemsWithImages.add({
              ...cartItem,
              'image_url': imageData.isNotEmpty ? imageData[0]['url'] : null,
            });
          } else {
            itemsWithImages.add({
              ...cartItem,
              'image_url': null,
            });
          }
        }

        setState(() {
          cartItems = itemsWithImages;
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Unauthorized. Please log in again.';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch cart items.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Something went wrong.';
        isLoading = false;
      });
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _placeOrder() async {
    final token = await _getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No token found. Please log in.')),
      );
      return;
    }

    double totalPrice = cartItems.fold(
      0,
          (sum, item) {
        final salesPrice = double.tryParse(item['Product']['sales_price'].toString()) ?? 0.0;
        final quantity = item['quantity'] is int ? item['quantity'] : int.tryParse(item['quantity'].toString()) ?? 0;
        return sum + (salesPrice * quantity);
      },
    );

    final url = Uri.parse('http://localhost:5000/orders');
    final orderData = {
      'totalAmount': totalPrice.toString(),
      'cartItems': cartItems.map((item) {
        return {
          'product_id': item['Product']['id'],
          'quantity': item['quantity'],
        };
      }).toList(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
        body: json.encode(orderData),
      );

      setState(() {
        cartItems.clear();
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Check the actual key or message returned by the API
        if (responseData['status'] == 'success' || responseData['message'] == 'Order placed successfully') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order placed successfully!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OrderConfirmationScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to place order: ${responseData['message']}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong.')),
      );
    }
  }


  Future<void> removeFromCart(int productId) async {
    setState(() {
      // Optimistically remove the item from the cart
      cartItems.removeWhere((item) => item['Product']['id'] == productId);
    });

    final url = Uri.parse('http://localhost:5000/cart');
    final token = await _getToken();

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'product_id': productId}),
      );

      if (response.statusCode == 200) {
        print('Item removed from cart');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item removed from cart')),
        );
      } else {
        print('Failed to remove item: ${response.body}');
        // Revert UI change if the deletion failed
        setState(() {
          _fetchCartItems(); // Reload cart to ensure consistency
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item')),
        );
      }
    } catch (e) {
      print('Error: $e');
      // Revert UI change on error
      setState(() {
        _fetchCartItems();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Could not remove item')),
      );
    }
  }


  Future<void> updateCartQuantity(int productId, int quantity) async {
    final url = Uri.parse('http://localhost:5000/cart');
    final token = await _getToken();

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'product_id': productId, 'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        print('Quantity updated successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quantity updated successfully')),
        );
      } else {
        print('Failed to update quantity: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quantity')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating quantity')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    double totalPrice = cartItems.fold(
      0,
          (sum, item) {
        final salesPrice = double.tryParse(item['Product']['sales_price'].toString()) ?? 0.0;
        final quantity = item['quantity'] is int ? item['quantity'] : int.tryParse(item['quantity'].toString()) ?? 0;
        return sum + (salesPrice * quantity);
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart Items'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : cartItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Your cart is empty.'),
            TextButton(
              onPressed: () {
                // Navigate to the ProductScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProdcutScreen()),
                );
              },
              child: Text(
                'Continue Shopping',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final cartItem = cartItems[index];
          final product = cartItem['Product'];
          final imageUrl = cartItem['image_url'];
          final int quantity = cartItem['quantity'];

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
                  Text('Price: ₹${product['sales_price']}'),
                  Text('WS Code: ${product['ws_code']}'),
                  Text('Quantity: $quantity'),
                ],
              ),
              trailing: SizedBox(
                width: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        removeFromCart(cartItem['Product']['id']);
                      },
                      color: Colors.red,
                    ),
                    DropdownButton<int>(
                      value: quantity,
                      onChanged: (value) {
                        if (value != null && value != quantity) {
                          setState(() {
                            cartItems[index]['quantity'] = value; // Update frontend immediately
                          });

                          // Send API request to update backend
                          updateCartQuantity(cartItem['Product']['id'], value);
                        }
                      },
                      items: List.generate(
                        cartItems[index]['Product']['max_quantity'] ?? 50, // Set a dynamic range based on product max quantity
                            (i) => DropdownMenuItem<int>(
                          value: i + 1,
                          child: Text('${i + 1}'),
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
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 4.0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ₹$totalPrice',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              ElevatedButton(
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Place Order',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class OrderConfirmationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Confirmation'),
      ),
      body: Center(
        child: Text('Your order has been placed successfully!'),
      ),
    );
  }
}
