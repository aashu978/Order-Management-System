const express = require('express');
const { placeOrder, getOrders } = require('../controller/orderController');
const authMiddleware = require('../middlewares/authMiddleware');
const { getAllOrders, updateOrderStatus, getOrderDetails } = require('../controller/authController');

const router = express.Router();

router.use(authMiddleware); // Protect all routes

router.post('/', placeOrder); // Place an order
router.get('/', getOrders);  // Get user orders with pagination
router.get('/admin', getAllOrders);  // Admin: View all orders
router.put('/admin/:id', updateOrderStatus);  // Admin: Update order status
router.get('/:orderId', getOrderDetails); // Get a specific order's full details based on orderId


module.exports = router;