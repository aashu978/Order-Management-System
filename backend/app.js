const express = require('express');
const sequelize = require('./config/database');
const authRoutes = require('./routes/authRoutes');
const cartRoutes = require('./routes/cartRoute');
const productRoutes = require('./routes/productRoute');
const orderRoutes = require('./routes/orderRoute');
const cors = require('cors'); // For enabling CORS
const multer = require('multer');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();

// PostgreSQL connection setup
const pool = new Pool({
  user: 'root',
  host: 'localhost',
  database: 'medkart',
  password: 'root',
  port: 5432,
});

// Enable CORS (optional but recommended for frontend-backend separation)
app.use(cors());

// Middleware to parse JSON requests
app.use(express.json());

// Setup Multer for file upload (limit to 5MB per file)
const storage = multer.memoryStorage(); // Store files in memory
const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB max file size
});

// Image upload API
app.post('/upload', upload.array('images', 10), async (req, res) => {
  console.log('Uploaded files:', req.files);
  console.log('Request body:', req.body);
  try {
    const client = await pool.connect();
    const { files, body: { ws_code } } = req;

    if (!ws_code) {
      return res.status(400).send('ws_code is required');
    }

    for (let file of files) {
      const imageData = file.buffer;
      const imageName = file.originalname;

      // Insert image along with ws_code into the database
      await client.query('INSERT INTO images (name, image, ws_code) VALUES ($1, $2, $3)', [imageName, imageData, ws_code]);
    }

    res.status(200).send('Images uploaded successfully');
    client.release();
  } catch (error) {
    console.error('Error uploading images:', error);
    res.status(500).send('Error uploading images');
  }
});

// Get all images
app.get('/images', async (req, res) => {
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT id, name, ws_code FROM images');
    
    const imageUrls = result.rows.map(row => ({
      id: row.id,
      name: row.name,
      ws_code: row.ws_code,
      url: `http://localhost:5000/image/${row.id}`  // Change port to 5000
    }));

    res.status(200).json(imageUrls);
    client.release();
  } catch (error) {
    console.error('Error retrieving images:', error);
    res.status(500).send('Error retrieving images');
  }
});

// Get single image by ID
app.get('/image/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT image, name, ws_code FROM images WHERE id = $1', [id]);

    if (result.rows.length > 0) {
      const image = result.rows[0];
      res.setHeader('Content-Type', 'image/jpeg');
      res.send(image.image);
    } else {
      res.status(404).send('Image not found');
    }

    client.release();
  } catch (error) {
    console.error('Error retrieving image:', error);
    res.status(500).send('Error retrieving image');
  }
});

// Get images by ws_code
app.get('/images/ws_code/:ws_code', async (req, res) => {
  const { ws_code } = req.params;
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT id, name, ws_code FROM images WHERE ws_code = $1', [ws_code]);
    
    const imageUrls = result.rows.map(row => ({
      id: row.id,
      name: row.name,
      ws_code: row.ws_code,
      url: `http://localhost:5000/image/${row.id}`  // Change port to 5000
    }));

    res.status(200).json(imageUrls);
    client.release();
  } catch (error) {
    console.error('Error retrieving images by ws_code:', error);
    res.status(500).send('Error retrieving images by ws_code');
  }
});

// Routes for other functionalities
app.use('/auth', authRoutes);
app.use('/products', productRoutes);
app.use('/cart', cartRoutes);
app.use('/orders', orderRoutes);

// Sync the database only for development or as needed
sequelize.sync({ alter: process.env.NODE_ENV === 'development' })
  .then(() => console.log('Database synced successfully.'))
  .catch(err => console.error('Error syncing database:', err));

// Global error handler for undefined routes
app.use((req, res, next) => {
  const error = new Error('Not Found');
  error.status = 404;
  next(error);
});

// Global error handler for catching any other errors
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({ message: err.message || 'Internal Server Error' });
});

module.exports = app;
