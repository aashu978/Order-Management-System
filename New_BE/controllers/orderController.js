const User = require('../models/User');
const Order = require('../models/Order');
const Cart = require('../models/Cart');
const Product = require('../models/Product');
const OrderItem = require('../models/OrderItem');


exports.placeOrder = async (req, res) => {
  try {
    const user_id = req.user.id;

    // Fetch items from cart
    const cartItems = await Cart.findAll({ where: { user_id }, include: [Product] });

    if (!cartItems.length) return res.status(400).json({ message: 'Cart is empty' });

    // Calculate total amount
    const totalAmount = cartItems.reduce((sum, item) => {
      return sum + item.quantity * item.Product.sales_price;
    }, 0);

    // Create order
    const order = await Order.create({ user_id, totalAmount });

    // Add order items (product details for each product in the cart)
    const orderItems = cartItems.map(item => ({
      order_id: order.id,
      product_id: item.Product.id,
      quantity: item.quantity,
      price: item.Product.sales_price,
    }));

    // Create order items
    await OrderItem.bulkCreate(orderItems);

    // Clear cart
    await Cart.destroy({ where: { user_id } });

    // Fetch the order with product details
    const fullOrder = await Order.findOne({
      where: { id: order.id },
      include: [
        {
          model: OrderItem,
          include: [Product], // Include product details
        },
      ],
    });

    // Return the response with order and product details
    res.status(201).json({
      message: 'Order placed successfully',
      order: fullOrder,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


exports.getOrders = async (req, res) => {
  try {
    const user_id = req.user.id;

    const limit = parseInt(req.query.limit, 10) || 10; // Default limit = 10
    const page = parseInt(req.query.page, 10) || 1; // Default page = 1
    const offset = (page - 1) * limit;

    // Fetch total orders count
    const totalOrders = await Order.count({ where: { user_id } });

    // Fetch paginated orders
    const orders = await Order.findAll({
      where: { user_id },
      limit,
      offset,
    });

    // Return paginated data and metadata
    res.status(200).json({
      orders,
      meta: {
        totalOrders,
        totalPages: Math.ceil(totalOrders / limit),
        currentPage: page,
        limit,
        hasMore: offset + limit < totalOrders, // Check if more data exists
      },
    });
  } catch (err) {
    res.status(500).json({
      error: 'An error occurred while fetching user orders.',
      details: err.message,
    });
  }
};




exports.getAllOrders = async (req, res) => {
  try {
    const limit = parseInt(req.query.limit, 10) || 10; // Number of orders per page
    const offset = parseInt(req.query.offset, 10) || 0; // Skip orders to fetch the correct page

    const orders = await Order.findAndCountAll({
      limit,
      offset,
      include: [
        {
          model: User,
          attributes: ['username'],
        },
      ],
    });

    if (orders.rows.length === 0) {
      return res.status(404).json({ message: 'No orders found.' });
    }

    const totalPages = Math.ceil(orders.count / limit);

    res.status(200).json({
      total: orders.count,
      totalPages: totalPages, // Added totalPages to the response
      orders: orders.rows,
    });
  } catch (err) {
    res.status(500).json({
      error: 'An error occurred while fetching all orders.',
      details: err.message,
    });
  }
};



  exports.updateOrderStatus = async (req, res) => {
    try {
      const { id } = req.params;
      const { status } = req.body;
  
      const order = await Order.findByPk(id);
      if (!order) return res.status(404).json({ message: 'Order not found' });
  
      order.status = status;
      await order.save();
  
      res.json({ message: 'Order status updated successfully', order });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
// Fetching a single order with all the details (order items, product details)
exports.getOrderDetails = async (req, res) => {
  try {
    const { orderId } = req.params; // Extract orderId from params

    // Fetch the order with its associated items and product details
    const order = await Order.findOne({
      where: { id: orderId },
      include: [
        {
          model: OrderItem,
          include: [
            {
              model: Product, // Include product details for each order item
              attributes: ['name', 'sales_price', 'category', 'images', 'tags']
            }
          ]
        }
      ]
    });

    if (!order) {
      return res.status(404).json({ message: 'Order not found' });
    }

    // Return the order with all details
    res.status(200).json({
      message: 'Order details retrieved successfully',
      order: order
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};