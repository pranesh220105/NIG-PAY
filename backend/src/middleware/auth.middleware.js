const jwt = require("jsonwebtoken");

function auth(req, res, next) {
  try {
    const header = req.headers.authorization || "";
    const parts = header.split(" ");

    if (parts.length !== 2 || parts[0] !== "Bearer") {
      return res.status(401).json({ message: "Missing token" });
    }

    const token = parts[1];
    const payload = jwt.verify(token, process.env.JWT_SECRET || "secret");

    const userId = payload?.id ?? payload?.userId;
    if (!userId) {
      return res.status(401).json({ message: "Invalid token payload" });
    }

    req.user = {
      id: Number(userId),
      email: payload.email,
      role: payload.role,
      exp: payload.exp,
    };
    next();
  } catch (e) {
    if (e?.name === "TokenExpiredError") {
      return res.status(401).json({ message: "Token expired" });
    }
    return res.status(401).json({ message: "Invalid token" });
  }
}

function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user?.role) return res.status(401).json({ message: "Unauthorized" });
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ message: "Forbidden" });
    }
    next();
  };
}

module.exports = { auth, requireRole };
