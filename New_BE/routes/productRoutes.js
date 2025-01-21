const express = require('express');
const { createProduct, getProducts } = require('../controllers/productController');
const { updateProduct, deleteProduct } = require('../controllers/productController');

const router = express.Router();

router.post('/', createProduct);
router.get('/', getProducts);
router.put('/:id', updateProduct);  // Update product
router.delete('/:id', deleteProduct);  // Delete product

module.exports = router;
