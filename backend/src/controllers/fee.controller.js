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

async function addFeeByStudentEmail(req, res) {
  try {
    const { studentEmail, amount, title, description, semester, dueDate, fineAmount } = req.body;
    if (!studentEmail || amount === undefined) {
      return res.status(400).json({ message: "studentEmail and amount are required" });
    }

    const user = await prisma.user.findUnique({
      where: { email: String(studentEmail).trim() },
    });
    if (!user) return res.status(404).json({ message: "Student not found" });
    if (String(user.role).toUpperCase() !== "STUDENT") {
      return res.status(400).json({ message: "Fee can only be added for STUDENT users" });
    }

    const numericAmount = Number(amount);
    if (!Number.isFinite(numericAmount) || numericAmount <= 0) {
      return res.status(400).json({ message: "Amount must be greater than 0" });
    }

    const fee = await prisma.fee.create({
      data: {
        userId: user.id,
        title: title ? String(title) : semester ? `${String(semester)} Fee` : "Fee",
        amount: numericAmount,
        description: JSON.stringify({
          note: description ? String(description) : null,
          semester: semester ? String(semester) : "General",
          dueDate: dueDate ? String(dueDate) : null,
          fineAmount: Number(fineAmount || 0),
        }),
        status: "PENDING",
      },
    });

    return res.status(201).json({ message: "Fee added", fee });
  } catch (e) {
    console.log("addFeeByStudentEmail error:", e);
    return res.status(500).json({ message: "Server error" });
  }
}

module.exports = { createFee, getMyFees, getAllFees, addFeeByStudentEmail };
