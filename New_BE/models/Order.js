const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');
const User = require('./User');
const OrderItem = require('./OrderItem'); // Import the OrderItem model

const Order = sequelize.define('Order', {
  status: {
    type: DataTypes.STRING,
    allowNull: false,
    defaultValue: 'Pending', // Pending, Confirmed, Delivered
  },
  totalAmount: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
}, {
  timestamps: true,
});

Order.belongsTo(User, { foreignKey: 'user_id', onDelete: 'CASCADE' });

// Establish a one-to-many relationship with OrderItem
Order.hasMany(OrderItem, { foreignKey: 'order_id' });

module.exports = Order;