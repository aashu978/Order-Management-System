const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  const authHeader = req.header('Authorization');
  
  if (!authHeader) {
    return res.status(401).json({ message: 'Access denied. No token provided.' });
  }

  if (!authHeader.startsWith('Bearer ')) {
    return res.status(400).json({ message: 'Invalid Authorization header format. Expected "Bearer <token>".' });
  }

  const token = authHeader.split(' ')[1]; // Extract the token after "Bearer"
  
  if (!token) {
    return res.status(401).json({ message: 'Access denied. Token not provided.' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // Attach decoded user info to the request
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token has expired.' });
    }
    return res.status(400).json({ message: 'Invalid token.' });
  }
};
