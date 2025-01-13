class CartItem {
  final String productName;
  final int quantity;
  final double price;
  final String imageUrl; // Optional if you want to display an image for the product

  CartItem({
    required this.productName,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  // Optionally, you can add methods to handle the cart item, like updating quantity
  void updateQuantity(int newQuantity) {
    // Add logic to update quantity
  }
}
