const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const prisma = require("../prisma");

// ✅ converts "student" -> "STUDENT", "Admin" -> "ADMIN"
function normalizeRole(role) {
  if (!role) return role;
  return String(role).trim().toUpperCase();
}

exports.register = async (req, res) => {
  try {
    const { email, password, role } = req.body;

    if (!email || !password || !role) {
      return res.status(400).json({ message: "email, password, role are required" });
    }

    const normalizedRole = normalizeRole(role);

    const existing = await prisma.user.findUnique({ where: { email } });
    if (existing) {
      return res.status(409).json({ message: "User already exists" });
    }

    const hashed = await bcrypt.hash(password, 10);

    const user = await prisma.user.create({
      data: {
        email,
        password: hashed,
        role: normalizedRole, // ✅ works with Enum (STUDENT/ADMIN)
      },
      select: { id: true, email: true, role: true },
    });

    return res.status(201).json({ message: "Registered", user });
  } catch (err) {
    console.error("REGISTER ERROR:", err);
    return res.status(500).json({
      message: "Server error",
      error: err?.message || String(err),
    });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password, role } = req.body;

    if (!email || !password || !role) {
      return res.status(400).json({ message: "email, password, role are required" });
    }

    const normalizedRole = normalizeRole(role);

    const user = await prisma.user.findUnique({ where: { email } });
    if (!user) return res.status(401).json({ message: "Invalid credentials" });

    // ✅ role match (case-insensitive)
    if (String(user.role).toUpperCase() !== normalizedRole) {
      return res.status(401).json({ message: "Role mismatch" });
    }

    const ok = await bcrypt.compare(password, user.password);
    if (!ok) return res.status(401).json({ message: "Invalid credentials" });

    const token = jwt.sign(
      { userId: user.id, role: user.role, email: user.email },
      process.env.JWT_SECRET || "secret",
      { expiresIn: "7d" }
    );

    return res.status(201).json({
      message: "Login success",
      token,
      user: { id: user.id, email: user.email, role: user.role },
    });
  } catch (err) {
    console.error("LOGIN ERROR:", err);
    return res.status(500).json({
      message: "Server error",
      error: err?.message || String(err),
    });
  }
};
