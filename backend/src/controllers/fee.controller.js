const prisma = require("../prisma");

async function createFee(req, res) {
  try {
    const { userId, title, amount, description } = req.body;

    if (!userId || !title || amount === undefined) {
      return res.status(400).json({ message: "userId, title, amount required" });
    }

    const user = await prisma.user.findUnique({ where: { id: Number(userId) } });
    if (!user) return res.status(404).json({ message: "User not found" });

    const fee = await prisma.fee.create({
      data: {
        userId: Number(userId),
        title: String(title),
        amount: Number(amount),
        description: description ? String(description) : null,
      },
    });

    return res.status(201).json({ message: "Fee created", fee });
  } catch (e) {
    console.log("createFee error:", e);
    return res.status(500).json({ message: "Server error" });
  }
}

async function getMyFees(req, res) {
  try {
    const fees = await prisma.fee.findMany({
      where: { userId: Number(req.user.id) },
      orderBy: { createdAt: "desc" },
    });
    return res.json({ fees });
  } catch (e) {
    console.log("getMyFees error:", e);
    return res.status(500).json({ message: "Server error" });
  }
}

async function getAllFees(req, res) {
  try {
    const fees = await prisma.fee.findMany({
      include: { user: { select: { id: true, email: true, role: true } } },
      orderBy: { createdAt: "desc" },
    });
    return res.json({ fees });
  } catch (e) {
    console.log("getAllFees error:", e);
    return res.status(500).json({ message: "Server error" });
  }
}

module.exports = { createFee, getMyFees, getAllFees };
