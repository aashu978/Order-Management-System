const app = require('./app');
require('dotenv').config();

const PORT = process.env.PORT || 5000;

// Start the server
const server = app.listen(PORT, () => {
  console.log(`Server running on port ${PORT} in ${process.env.NODE_ENV || 'development'} mode.`);
});

// Graceful shutdown on termination signals (e.g., Ctrl + C)
const shutdown = (signal) => {
  console.log(`Received ${signal}. Closing server...`);
  server.close(() => {
    console.log('Closed out remaining connections.');
    process.exit(0);
  });

  // If there are ongoing requests and they don't finish within 10 seconds, force exit
  setTimeout(() => {
    console.error('Forcing server shutdown due to delay.');
    process.exit(1);
  }, 10000);
};

process.on('SIGINT', shutdown); // Handle Ctrl + C
process.on('SIGTERM', shutdown); // Handle termination signal

// Handle server errors
server.on('error', (err) => {
  console.error('Failed to start server:', err.message);
});

// Handle uncaught exceptions (critical errors, program will exit after logging)
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  if (process.env.NODE_ENV === 'production') {
    console.error('Critical error in production, shutting down...');
    process.exit(1); // Exit to avoid unknown state
  }
});

// Handle unhandled promise rejections (async errors)
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled Rejection at:', promise, 'reason:', reason);
  if (process.env.NODE_ENV === 'production') {
    console.error('Unhandled rejection in production, shutting down...');
    process.exit(1); // Exit to avoid unknown state
  }
});
