const jwt = require("jsonwebtoken");

const authMiddleware = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    // 👉 token check
    if (!authHeader) {
      return res.status(401).json({ message: "No token ❌" });
    }

    // 👉 Bearer TOKEN
    const token = authHeader.split(" ")[1];

    if (!token) {
      return res.status(401).json({ message: "Invalid token ❌" });
    }

    // 👉 verify
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // 👉 userId save
    req.userId = decoded.userId;

    next();
  } catch (error) {
    res.status(401).json({ message: "Token failed ❌" });
  }
};

module.exports = authMiddleware;