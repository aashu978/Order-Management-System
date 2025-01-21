const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const Product = require('./Product'); // Import Product model

const OrderItem = sequelize.define('OrderItem', {
  order_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'Orders',
      key: 'id',
    },
  },
  product_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'Products',
      key: 'id',
    },
  },
  quantity: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
}, {
  timestamps: true,
});

OrderItem.belongsTo(Product, { foreignKey: 'product_id' });

module.exports = OrderItem;