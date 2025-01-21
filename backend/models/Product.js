const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

const Product = sequelize.define('Product', {
  name: { type: DataTypes.STRING, allowNull: false },
  ws_code: { type: DataTypes.INTEGER, allowNull: false, unique: true },
  sales_price: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
  mrp: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
  package_size: { type: DataTypes.INTEGER, allowNull: false },
  images: { type: DataTypes.ARRAY(DataTypes.INTEGER), allowNull: true }, // Store image IDs
  tags: { type: DataTypes.ARRAY(DataTypes.STRING), allowNull: true },
  category: { type: DataTypes.STRING, allowNull: true },
}, { timestamps: true });

module.exports = Product;
