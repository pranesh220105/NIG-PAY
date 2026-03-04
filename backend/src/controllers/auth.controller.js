const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const { OAuth2Client } = require("google-auth-library");
const prisma = require("../prisma");

const DEFAULT_GOOGLE_CLIENT_ID =
  "623885943651-084aveak7dhv40u32rbre1bqotjncngf.apps.googleusercontent.com";
const googleClient = new OAuth2Client(process.env.GOOGLE_CLIENT_ID || DEFAULT_GOOGLE_CLIENT_ID);

// ✅ converts "student" -> "STUDENT", "Admin" -> "ADMIN"
function normalizeRole(role) {
  if (!role) return role;
  return String(role).trim().toUpperCase();
}

function signAuthToken(user) {
  return jwt.sign(
    { id: user.id, role: user.role, email: user.email },
    process.env.JWT_SECRET || "secret",
    { expiresIn: "12h" }
  );
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

    const token = signAuthToken(user);

    return res.status(201).json({
      message: "Login success",
      token,
      expiresIn: "12h",
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

exports.googleLogin = async (req, res) => {
  try {
    const { idToken, role } = req.body;
    if (!idToken || !role) {
      return res.status(400).json({ message: "idToken and role are required" });
    }

    const normalizedRole = normalizeRole(role);
    if (!["STUDENT", "ADMIN"].includes(normalizedRole)) {
      return res.status(400).json({ message: "Invalid role" });
    }

    const verifyOptions = { idToken };
    verifyOptions.audience = process.env.GOOGLE_CLIENT_ID || DEFAULT_GOOGLE_CLIENT_ID;

    const ticket = await googleClient.verifyIdToken(verifyOptions);
    const payload = ticket.getPayload();
    if (!payload?.email) {
      return res.status(400).json({ message: "Google account email not available" });
    }

    const email = String(payload.email).trim().toLowerCase();
    let user = await prisma.user.findUnique({ where: { email } });

    if (user) {
      if (String(user.role).toUpperCase() !== normalizedRole) {
        return res.status(401).json({ message: "Role mismatch" });
      }
    } else {
      const hashed = await bcrypt.hash(`GOOGLE_${payload.sub}_${Date.now()}`, 10);
      user = await prisma.user.create({
        data: {
          email,
          password: hashed,
          role: normalizedRole,
        },
      });
    }

    const token = signAuthToken(user);
    return res.status(200).json({
      message: "Google login success",
      token,
      expiresIn: "12h",
      user: { id: user.id, email: user.email, role: user.role },
    });
  } catch (err) {
    console.error("GOOGLE LOGIN ERROR:", err);
    return res.status(401).json({
      message: "Google sign-in failed",
      error: err?.message || String(err),
    });
  }
};
