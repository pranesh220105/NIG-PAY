const bcrypt = require("bcryptjs");
const prisma = require("../prisma");

function parseFeeMeta(description) {
  if (!description) return {};
  try {
    return JSON.parse(description);
  } catch (_) {
    return {};
  }
}

function stringifyFeeMeta(meta) {
  return JSON.stringify(meta);
}

async function createStudent(req, res) {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ message: "email and password are required" });
    }

    const existing = await prisma.user.findUnique({ where: { email: String(email).trim() } });
    if (existing) return res.status(409).json({ message: "Student already exists" });

    const hashed = await bcrypt.hash(String(password), 10);
    const user = await prisma.user.create({
      data: {
        email: String(email).trim(),
        password: hashed,
        role: "STUDENT",
      },
      select: { id: true, email: true, role: true, createdAt: true },
    });
    return res.status(201).json({ message: "Student created", student: user });
  } catch (e) {
    console.log("createStudent error:", e);
    return res.status(500).json({ message: "Server error" });
  }
}

async function setSemesterFee(req, res) {
  try {
    const { studentEmail, semester, amount, dueDate, fineAmount } = req.body;
    if (!studentEmail || !semester || amount === undefined) {
      return res.status(400).json({ message: "studentEmail, semester, amount are required" });
    }

    const user = await prisma.user.findUnique({ where: { email: String(studentEmail).trim() } });
    if (!user || String(user.role).toUpperCase() !== "STUDENT") {
      return res.status(404).json({ message: "Student not found" });
    }

    const numericAmount = Number(amount);
    if (!Number.isFinite(numericAmount) || numericAmount <= 0) {
      return res.status(400).json({ message: "Amount must be greater than 0" });
    }

    const meta = stringifyFeeMeta({
      semester: String(semester).trim(),
      dueDate: dueDate ? String(dueDate) : null,
      fineAmount: Number(fineAmount || 0),
    });

    const fee = await prisma.fee.create({
      data: {
        userId: user.id,
        title: `${String(semester).trim()} Fee`,
        amount: numericAmount,
        description: meta,
        status: "PENDING",
      },
    });

    return res.status(201).json({ message: "Semester fee set", fee });
  } catch (e) {
    console.log("setSemesterFee error:", e);
    return res.status(500).json({ message: "Server error" });
  }
}

async function markFee(req, res) {
  try {
    const { feeId, amountPaid, markAs } = req.body;
    if (!feeId || amountPaid === undefined) {
      return res.status(400).json({ message: "feeId and amountPaid are required" });
    }

    const fee = await prisma.fee.findUnique({ where: { id: Number(feeId) } });
    if (!fee) return res.status(404).json({ message: "Fee not found" });
    if (String(fee.status).toUpperCase() === "PAID") {
      return res.status(400).json({ message: "Fee already paid" });
    }

    const amount = Number(amountPaid);
    if (!Number.isFinite(amount) || amount <= 0) {
      return res.status(400).json({ message: "amountPaid must be greater than 0" });
    }
    if (amount > Number(fee.amount)) {
      return res.status(400).json({ message: "amountPaid exceeds pending fee amount" });
    }

    if (markAs && String(markAs).toUpperCase() === "PAID") {
      const updated = await prisma.fee.update({
        where: { id: fee.id },
        data: { status: "PAID" },
      });
      return res.json({ message: "Fee marked paid", fee: updated });
    }

    if (amount === Number(fee.amount)) {
      const updated = await prisma.fee.update({
        where: { id: fee.id },
        data: { status: "PAID" },
      });
      return res.json({ message: "Fee marked paid", fee: updated });
    }

    let paidEntry;
    await prisma.$transaction(async (tx) => {
      const remaining = Number(fee.amount) - amount;
      await tx.fee.update({
        where: { id: fee.id },
        data: { amount: remaining },
      });
      paidEntry = await tx.fee.create({
        data: {
          userId: fee.userId,
          title: `${fee.title} (Admin partial payment)`,
          amount,
          status: "PAID",
          description: fee.description,
        },
      });
    });

    const meta = parseFeeMeta(fee.description);
    return res.json({
      message: "Fee partially paid",
      payment: paidEntry,
      semester: meta.semester ?? "General",
    });
  } catch (e) {
    console.log("markFee error:", e);
    return res.status(500).json({ message: "Server error" });
  }
}

module.exports = { createStudent, setSemesterFee, markFee };
