import 'package:flutter/material.dart';
import '../models/cart_item.dart'; // Import the CartItem model

class CartItemTile extends StatelessWidget {
  final CartItem cartItem;

  CartItemTile({required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(cartItem.imageUrl), // Display the product image
      title: Text(cartItem.productName),
      subtitle: Text("Quantity: ${cartItem.quantity} x \$${cartItem.price}"),
      trailing: IconButton(
        icon: Icon(Icons.remove_shopping_cart),
        onPressed: () {
          // Call cartProvider.removeCartItem(cartItem) to remove the item
        },
      ),
    );
  }
}
