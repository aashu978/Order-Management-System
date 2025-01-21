const { body, param, query } = require('express-validator');

exports.validateProduct = [
  body('name').isString().notEmpty(),
  body('ws_code').isInt({ min: 0 }),
  body('sales_price').isFloat({ min: 0 }),
  body('mrp').isFloat({ min: 0 }),
  body('package_size').isInt({ min: 0 }),
  body('images').isArray(),
  body('tags').isArray(),
  body('category').isString().optional(),
];

exports.validateCart = [
  body('product_id').isInt(),
  body('quantity').isInt({ min: 1 }),
];

exports.validateOrderUpdate = [
  param('id').isInt(),
  body('status').isString().isIn(['Pending', 'Confirmed', 'Delivered']),
];
