const prisma = require("../prisma");

function toSafeFee(fee) {
  return {
    id: fee.id,
    title: fee.title,
    amount: fee.amount,
    status: fee.status,
    description: fee.description,
    createdAt: fee.createdAt,
    updatedAt: fee.updatedAt,
  };
}

function parseFeeMeta(description) {
  if (!description) return {};
  try {
    return JSON.parse(description);
  } catch (_) {
    return {};
  }
}

function isOverdue(dueDate) {
  if (!dueDate) return false;
  const due = new Date(dueDate);
  if (Number.isNaN(due.getTime())) return false;
  return due.getTime() < Date.now();
}

exports.getStudentDashboard = async (req, res) => {
  try {
    const fees = await prisma.fee.findMany({
      where: { userId: Number(req.user.id), isActive: true },
      select: { amount: true, status: true, description: true },
    });

    const totalFee = fees.reduce((sum, fee) => sum + Number(fee.amount || 0), 0);
    const paidFee = fees
      .filter((fee) => String(fee.status).toUpperCase() === "PAID")
      .reduce((sum, fee) => sum + Number(fee.amount || 0), 0);
    const pendingFee = Math.max(totalFee - paidFee, 0);
    const pendingFees = fees.filter((fee) => String(fee.status).toUpperCase() !== "PAID");
    const totalFineDue = pendingFees.reduce((sum, fee) => {
      const meta = parseFeeMeta(fee.description);
      if (!isOverdue(meta.dueDate)) return sum;
      return sum + Number(meta.fineAmount || 0);
    }, 0);

    const semesterMap = new Map();
    for (const fee of fees) {
      const meta = parseFeeMeta(fee.description);
      const semester = (meta.semester || "General").toString();
      if (!semesterMap.has(semester)) {
        semesterMap.set(semester, {
          semester,
          total: 0,
          paid: 0,
          pending: 0,
          fineDue: 0,
        });
      }
      const item = semesterMap.get(semester);
      const amount = Number(fee.amount || 0);
      item.total += amount;
      if (String(fee.status).toUpperCase() === "PAID") {
        item.paid += amount;
      } else {
        item.pending += amount;
        if (isOverdue(meta.dueDate)) item.fineDue += Number(meta.fineAmount || 0);
      }
    }
    const semesterBreakdown = Array.from(semesterMap.values());

    return res.status(200).json({
      totalFee,
      paidFee,
      pendingFee,
      totalFineDue,
      semesterBreakdown,
      message: "Dashboard loaded",
    });
  } catch (err) {
    console.error("STUDENT DASHBOARD ERROR:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

exports.getStudentPayments = async (req, res) => {
  try {
    const payments = await prisma.fee.findMany({
      where: {
        userId: Number(req.user.id),
        status: "PAID",
      },
      orderBy: { updatedAt: "desc" },
    });
    return res.status(200).json({ payments: payments.map(toSafeFee) });
  } catch (err) {
    console.error("GET STUDENT PAYMENTS ERROR:", err);
    return res.status(500).json({ message: "Server error" });
  }
};

exports.makePayment = async (req, res) => {
  try {
    const amount = Number(req.body?.amount || 0);
    if (!Number.isFinite(amount) || amount <= 0) {
      return res.status(400).json({ message: "Valid payment amount is required" });
    }

    const userId = Number(req.user.id);
    const pendingFees = await prisma.fee.findMany({
      where: { userId, status: "PENDING", isActive: true },
      orderBy: { createdAt: "asc" },
    });

    const totalPending = pendingFees.reduce((sum, fee) => sum + Number(fee.amount || 0), 0);
    if (totalPending <= 0) {
      return res.status(400).json({ message: "No pending fees to pay" });
    }
    if (amount > totalPending) {
      return res.status(400).json({ message: `Amount exceeds pending fee (max ${totalPending})` });
    }

    let remaining = amount;
    await prisma.$transaction(async (tx) => {
      for (const fee of pendingFees) {
        if (remaining <= 0) break;

        const feeAmount = Number(fee.amount);
        if (feeAmount <= remaining) {
          await tx.fee.update({
            where: { id: fee.id },
            data: { status: "PAID" },
          });
          remaining -= feeAmount;
          continue;
        }

        await tx.fee.update({
          where: { id: fee.id },
          data: { amount: feeAmount - remaining },
        });

        await tx.fee.create({
          data: {
            userId,
            title: `${fee.title} (Part payment)`,
            amount: remaining,
            status: "PAID",
            description: `Part payment against fee #${fee.id}`,
          },
        });
        remaining = 0;
      }
    });

    const fees = await prisma.fee.findMany({
      where: { userId, isActive: true },
      select: { amount: true, status: true },
    });
    const totalFee = fees.reduce((sum, fee) => sum + Number(fee.amount || 0), 0);
    const paidFee = fees
      .filter((fee) => String(fee.status).toUpperCase() === "PAID")
      .reduce((sum, fee) => sum + Number(fee.amount || 0), 0);
    const pendingFee = Math.max(totalFee - paidFee, 0);

    return res.status(200).json({
      message: "Payment successful",
      paidAmount: amount,
      dashboard: { totalFee, paidFee, pendingFee },
    });
  } catch (err) {
    console.error("MAKE PAYMENT ERROR:", err);
    return res.status(500).json({ message: "Server error" });
  }
};
