const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const User = require('./User');
const Product = require('./Product');

const Cart = sequelize.define('Cart', {
  quantity: {
    type: DataTypes.INTEGER,
    allowNull: false,
    validate: {
      min: 1, // Quantity must be at least 1
    },
  },
}, {
  timestamps: true,
});

Cart.belongsTo(User, { foreignKey: 'user_id', onDelete: 'CASCADE' });
Cart.belongsTo(Product, { foreignKey: 'product_id', onDelete: 'CASCADE' });

module.exports = Cart;
