const express = require('express');
const { addToCart, getCart, updateCart, removeFromCart } = require('../controllers/cartController');
const authMiddleware = require('../middlewares/authMiddleware');
const router = express.Router();

router.use(authMiddleware); // Protect all routes

router.post('/', addToCart);
router.get('/', getCart);
router.put('/', updateCart);
router.delete('/', removeFromCart);

module.exports = router;
