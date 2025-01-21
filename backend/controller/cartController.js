const Cart = require('../models/Cart');
const Product = require('../models/Product');

exports.addToCart = async (req, res) => {
  try {
    const { product_id, quantity } = req.body;
    const user_id = req.user.id; // Assuming user ID is available via middleware

    // Check if the product exists
    const product = await Product.findByPk(product_id);
    if (!product) return res.status(404).json({ message: 'Product not found' });

    // Check if the product is already in the cart
    const existingCartItem = await Cart.findOne({ where: { user_id, product_id } });
    if (existingCartItem) {
      // Update the quantity
      existingCartItem.quantity += quantity;
      await existingCartItem.save();
      return res.json({ message: 'Cart updated successfully', cart: existingCartItem });
    }

    // Add new item to the cart
    const cart = await Cart.create({ user_id, product_id, quantity });
    res.status(201).json({ message: 'Product added to cart', cart });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getCart = async (req, res) => {
  try {
    const user_id = req.user.id;
    const cartItems = await Cart.findAll({
      where: { user_id },
      include: [{ model: Product }],
    });
    res.json(cartItems);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateCart = async (req, res) => {
  try {
    const { product_id, quantity } = req.body;
    const user_id = req.user.id;

    const cartItem = await Cart.findOne({ where: { user_id, product_id } });
    if (!cartItem) return res.status(404).json({ message: 'Item not found in cart' });

    cartItem.quantity = quantity;
    await cartItem.save();
    res.json({ message: 'Cart updated successfully', cart: cartItem });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.removeFromCart = async (req, res) => {
  try {
    const { product_id } = req.body;
    const user_id = req.user.id;

    const result = await Cart.destroy({ where: { user_id, product_id } });
    if (!result) return res.status(404).json({ message: 'Item not found in cart' });

    res.json({ message: 'Item removed from cart' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
