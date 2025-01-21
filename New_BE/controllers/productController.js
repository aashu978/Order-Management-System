const Product = require('../models/Product');
const { Op, literal } = require('sequelize');  // Ensure this is only declared once


exports.createProduct = async (req, res) => {
  try {
    const { name, ws_code, sales_price, mrp, package_size, images, tags, category } = req.body;
    const product = await Product.create({ name, ws_code, sales_price, mrp, package_size, images, tags, category });
    res.status(201).json({ message: 'Product created successfully', product });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};


exports.getProducts = async (req, res) => {
  try {
    const { search, ws_code, limit = 10, offset = 0, suggest } = req.query;

    const parsedLimit = parseInt(limit);
    const parsedOffset = parseInt(offset);
    if (isNaN(parsedLimit) || isNaN(parsedOffset) || parsedLimit <= 0 || parsedOffset < 0) {
      return res.status(400).json({ error: 'Invalid limit or offset value' });
    }

    const where = {};
    if (search) {
      where[Op.or] = [
        { name: { [Op.iLike]: `%${search}%` } },
        { category: { [Op.iLike]: `%${search}%` } },
        // Cast ws_code to text for string search
        literal(`CAST("ws_code" AS TEXT) ILIKE '%${search}%'`),
      ];
    }

    if (ws_code) {
      where.ws_code = ws_code;
    }

    // Check if the request is for suggestions
    if (suggest) {
      const suggestions = await Product.findAll({
        where,
        attributes: ['id', 'name'], // Return only necessary fields
        limit: parsedLimit, // You can adjust the limit for suggestions
        order: [['name', 'ASC']], // Optional: Order alphabetically
      });

      return res.status(200).json({
        success: true,
        suggestions: suggestions.map((product) => ({
          id: product.id,
          name: product.name,
        })),
      });
    }

    // Regular product fetch
    const products = await Product.findAndCountAll({
      where,
      limit: parsedLimit,
      offset: parsedOffset,
      order: [['createdAt', 'DESC']],
    });

    res.status(200).json({
      success: true,
      total: products.count,
      pages: Math.ceil(products.count / parsedLimit),
      products: products.rows,
    });
  } catch (err) {
    console.error('Error fetching products:', err);
    res.status(500).json({ success: false, error: 'An unexpected error occurred' });
  }
};



exports.updateProduct = async (req, res) => {
    try {
      const { id } = req.params;
      const updatedData = req.body;
  
      const product = await Product.findByPk(id);
      if (!product) return res.status(404).json({ message: 'Product not found' });
  
      await product.update(updatedData);
      res.json({ message: 'Product updated successfully', product });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };
  
  
  exports.deleteProduct = async (req, res) => {
    try {
      const { id } = req.params;
  
      const result = await Product.destroy({ where: { id } });
      if (!result) return res.status(404).json({ message: 'Product not found' });
  
      res.json({ message: 'Product deleted successfully' });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  };