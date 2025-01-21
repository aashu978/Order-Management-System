import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetails extends StatefulWidget {
  final int orderId;

  OrderDetails({required this.orderId});

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  bool isLoading = true;
  String errorMessage = '';
  Map<String, dynamic> orderDetails = {};

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
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

    final url = Uri.parse('http://localhost:5000/orders/${widget.orderId}');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        setState(() {
          orderDetails = responseData['order'];
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        setState(() {
          errorMessage = 'Unauthorized. Please log in again.';
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch order details.';
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Order Details'),
      content: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${orderDetails['id']}'),
            Text('Status: ${orderDetails['status']}'),
            Text('Total Amount: ₹${orderDetails['totalAmount']}'),
            Text('Created At: ${orderDetails['createdAt']}'),
            Text('Updated At: ${orderDetails['updatedAt']}'),
            SizedBox(height: 10),
            Text('Order Items:'),
            ...orderDetails['OrderItems'].map<Widget>((item) {
              return ListTile(
                title: Text(item['Product']['name']),
                subtitle: Text('Quantity: ${item['quantity']} - Price: ₹${item['price']}'),
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
}