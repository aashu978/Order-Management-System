import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/order_details.dart';

class OrderScreen extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isLoading = false; // For the initial loading
  bool isLoadingMore = false; // For loading additional pages
  bool hasMore = true; // Flag to check if more orders can be fetched
  String errorMessage = '';
  List<dynamic> orders = [];
  int currentPage = 1; // Current page
  final int limit = 10; // Items per page

  @override
  void initState() {
    super.initState();
    _fetchOrders(); // Fetch the initial set of orders
  }

  Future<void> _fetchOrders() async {
    // Prevent duplicate requests
    if (isLoading || isLoadingMore || !hasMore) return;

    setState(() {
      if (orders.isEmpty) {
        isLoading = true; // Show main loader only if no orders are loaded
      } else {
        isLoadingMore = true; // Show bottom loader for pagination
      }
      errorMessage = '';
    });


    final token = await _getToken();

    if (token == null) {
      setState(() {
        errorMessage = 'No token found. Please log in.';
        isLoading = false;
        isLoadingMore = false;
      });
      return;
    }

    final url = Uri.parse('http://localhost:5000/orders?page=$currentPage&limit=$limit');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );


      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> newOrders = responseData['orders'];
        final metaData = responseData['meta'];

        setState(() {
          orders.addAll(newOrders); // Append new orders to the list
          hasMore = metaData['hasMore']; // Check if more pages are available
          currentPage++; // Increment the page for the next request
          isLoading = false;
          isLoadingMore = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Unauthorized. Please log in again.';
          isLoading = false;
          isLoadingMore = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch orders.';
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        errorMessage = 'Something went wrong.';
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
        backgroundColor: Colors.teal,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollEndNotification &&
              scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent) {
            _fetchOrders(); // Fetch more orders when the user scrolls to the bottom
          }
          return false;
        },
        child: isLoading && orders.isEmpty
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : ListView.builder(
          itemCount: orders.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == orders.length) {
              // Show loader at the bottom if more pages are available
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final order = orders[index];

            return Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(8.0),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order['id']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: _getStatusColor(order['status']),
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        // Handle the button press if necessary
                      },
                      child: Text(
                        'Status: ${order['status']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Amount: ₹${order['totalAmount']}'),
                    Text('Created At: ${order['createdAt']}'),
                    SizedBox(height: 10),
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
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.yellow;
      case 'confirm':
        return Colors.black;
      case 'cancel':
        return Colors.red;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
