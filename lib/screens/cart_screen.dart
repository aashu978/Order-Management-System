import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart'; // Import CartProvider
import '../widgets/cart_item_tile.dart'; // Import CartItemTile

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context); // Access CartProvider
    final cartItems = cartProvider.cartItems;

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      body: cartItems.isEmpty
          ? Center(child: Text("Your cart is empty"))
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          return CartItemTile(cartItem: cartItems[index]);
        },
      ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            // Place order functionality
            cartProvider.placeOrder();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Order placed successfully")),
            );
          },
          child: Text("Place Order"),
        ),
      ),
    );
  }
}
