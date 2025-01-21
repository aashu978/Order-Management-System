const express = require('express');
const { createProduct, getProducts } = require('../controller/productController');
const { updateProduct, deleteProduct } = require('../controller/productController');

const router = express.Router();

router.post('/', createProduct);
router.get('/', getProducts);
router.put('/:id', updateProduct);  // Update product
router.delete('/:id', deleteProduct);  // Delete product

module.exports = router;
