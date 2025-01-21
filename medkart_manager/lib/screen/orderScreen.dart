import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/orderDetails.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isLoading = true;
  String errorMessage = '';
  List<dynamic> orders = [];
  int currentPage = 1;
  int totalPages = 1; // New variable for total pages

  @override
  void initState() {
    super.initState();
    _fetchOrders(currentPage);
  }

  // Fetch all orders with pagination
  Future<void> _fetchOrders(int page) async {
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

    final url = Uri.parse('http://localhost:5000/orders/admin?limit=10&offset=${(page - 1) * 10}'); // Include limit and offset
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          orders = responseData['orders'];
          totalPages = responseData['totalPages']; // Update totalPages
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Unauthorized. Please log in again.';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch orders.';
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

  // Get the authentication token from shared preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Update the order status
  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    final token = await _getToken();

    if (token == null) {
      setState(() {
        errorMessage = 'No token found. Please log in.';
      });
      return;
    }

    final url = Uri.parse('http://localhost:5000/orders/admin/$orderId');

    if (newStatus == null || newStatus.isEmpty) {
      setState(() {
        errorMessage = 'Invalid status.';
      });
      return;
    }

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': newStatus}),
      );

      if (response.statusCode == 200) {
        final updatedOrder = json.decode(response.body)['order'];
        setState(() {
          orders = orders.map((order) {
            if (order['id'] == updatedOrder['id']) {
              return updatedOrder;
            }
            return order;
          }).toList();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to $newStatus')),
        );

        _fetchOrders(currentPage);
      } else {
        setState(() {
          errorMessage = 'Failed to update order status: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Something went wrong. Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Orders'),
        backgroundColor: Colors.orange,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Order #${order['id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${order['status']}'),
                        Text('Total: ₹${order['totalAmount']}'),
                        Text('User: ${order['User']['username']}'),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => OrderDetails(orderId: order['id']),
                            );
                          },
                          child: Text(
                            'View Order History',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: DropdownButton<String>(
                      value: order['status'],
                      onChanged: (String? newStatus) {
                        if (newStatus != null) {
                          _updateOrderStatus(order['id'], newStatus);
                        }
                      },
                      items: <String>['Pending', 'Confirmed', 'Delivered', 'Cancel']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: currentPage > 1
                    ? () {
                  setState(() {
                    currentPage--;
                  });
                  _fetchOrders(currentPage);
                }
                    : null,
              ),
              Text('Page $currentPage of $totalPages'),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: currentPage < totalPages
                    ? () {
                  setState(() {
                    currentPage++;
                  });
                  _fetchOrders(currentPage);
                }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
