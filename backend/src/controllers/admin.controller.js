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

function buildFeePayload({ semester, dueDate, fineAmount, feeType, feeLabel, amount, userId }) {
  const numericAmount = Number(amount);
  const normalizedFeeType = String(feeType || "SEMESTER_FEE").trim().toUpperCase();
  const normalizedSemester = String(semester || "").trim();
  const normalizedLabel = String(feeLabel || "").trim();
  const typeTitles = {
    SEMESTER_FEE: normalizedSemester ? `${normalizedSemester} Fee` : "Semester Fee",
    PAPER_FEE: normalizedSemester ? `${normalizedSemester} Paper Fee` : "Paper Fee",
    COURSE_FEE: normalizedSemester ? `${normalizedSemester} Course Fee` : "Course Fee",
    BUS_FEE: normalizedSemester ? `${normalizedSemester} Bus Fee` : "Bus Fee",
    HOSTEL_FEE: normalizedSemester ? `${normalizedSemester} Hostel Fee` : "Hostel Fee",
    LIBRARY_FEE: normalizedSemester ? `${normalizedSemester} Library Fee` : "Library Fee",
  };
  const finalTitle = normalizedLabel || typeTitles[normalizedFeeType] || "College Fee";
  const meta = stringifyFeeMeta({
    semester: normalizedSemester || "General",
    dueDate: dueDate ? String(dueDate) : null,
    fineAmount: Number(fineAmount || 0),
    feeType: normalizedFeeType,
    feeLabel: finalTitle,
  });

  return {
    userId,
    title: finalTitle,
    amount: numericAmount,
    description: meta,
    status: "PENDING",
  };
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

async function listStudents(req, res) {
  try {
    const students = await prisma.user.findMany({
      where: { role: "STUDENT" },
      orderBy: { createdAt: "desc" },
      select: {
        id: true,
        email: true,
        role: true,
        createdAt: true,
        _count: {
          select: { fees: true },
        },
      },
    });
    return res.json({
      students: students.map((student) => ({
        id: student.id,
        email: student.email,
        role: student.role,
        createdAt: student.createdAt,
        feeCount: student._count.fees,
      })),
    });
  } catch (e) {
    console.log("listStudents error:", e);
    return res.status(500).json({ message: "Server error" });
  }
}

async function getAdminOverview(req, res) {
  try {
    const [studentCount, paidAggregate, recentPaidFees] = await Promise.all([
      prisma.user.count({ where: { role: "STUDENT" } }),
      prisma.fee.aggregate({
        where: { status: "PAID" },
        _sum: { amount: true },
        _count: { id: true },
      }),
      prisma.fee.findMany({
        where: { status: "PAID" },
        orderBy: { updatedAt: "desc" },
        take: 8,
        include: {
          user: {
            select: { email: true },
          },
        },
      }),
    ]);

    return res.json({
      summary: {
        studentCount,
        collectedAmount: Number(paidAggregate._sum.amount || 0),
        paidEntries: Number(paidAggregate._count.id || 0),
      },
      recentPayments: recentPaidFees.map((fee) => ({
        id: fee.id,
        title: fee.title,
        amount: fee.amount,
        status: fee.status,
        updatedAt: fee.updatedAt,
        studentEmail: fee.user?.email || "Unknown",
      })),
    });
  } catch (e) {
    console.log("getAdminOverview error:", e);
    return res.status(500).json({ message: "Server error" });
  }
}

async function setSemesterFee(req, res) {
  try {
    const { studentEmail, semester, amount, dueDate, fineAmount, feeType, feeLabel } = req.body;
    if (!studentEmail || amount === undefined) {
      return res.status(400).json({ message: "studentEmail and amount are required" });
    }

    const user = await prisma.user.findUnique({ where: { email: String(studentEmail).trim() } });
    if (!user || String(user.role).toUpperCase() !== "STUDENT") {
      return res.status(404).json({ message: "Student not found" });
    }

    const numericAmount = Number(amount);
    if (!Number.isFinite(numericAmount) || numericAmount <= 0) {
      return res.status(400).json({ message: "Amount must be greater than 0" });
    }

    const fee = await prisma.fee.create({
      data: buildFeePayload({
        semester,
        dueDate,
        fineAmount,
        feeType,
        feeLabel,
        amount: numericAmount,
        userId: user.id,
      }),
    });

    return res.status(201).json({ message: "Semester fee set", fee });
  } catch (e) {
    console.log("setSemesterFee error:", e);
    return res.status(500).json({ message: "Server error" });
  }
}

async function assignFeeToStudents(req, res) {
  try {
    const { studentIds, applyToAll, semester, amount, dueDate, fineAmount, feeType, feeLabel } = req.body;

    const numericAmount = Number(amount);
    if (!Number.isFinite(numericAmount) || numericAmount <= 0) {
      return res.status(400).json({ message: "Amount must be greater than 0" });
    }

    let users = [];
    if (applyToAll) {
      users = await prisma.user.findMany({
        where: { role: "STUDENT" },
        select: { id: true, email: true },
      });
    } else {
      const ids = Array.isArray(studentIds)
        ? studentIds.map((id) => Number(id)).filter((id) => Number.isFinite(id) && id > 0)
        : [];
      if (ids.length === 0) {
        return res.status(400).json({ message: "Select at least one student" });
      }
      users = await prisma.user.findMany({
        where: { role: "STUDENT", id: { in: ids } },
        select: { id: true, email: true },
      });
    }

    if (users.length === 0) {
      return res.status(404).json({ message: "No students found" });
    }

    const createdFees = await prisma.$transaction(
      users.map((user) =>
        prisma.fee.create({
          data: buildFeePayload({
            semester,
            dueDate,
            fineAmount,
            feeType,
            feeLabel,
            amount: numericAmount,
            userId: user.id,
          }),
        })
      )
    );

    return res.status(201).json({
      message: "Fee assigned successfully",
      count: createdFees.length,
      students: users.map((user) => user.email),
    });
  } catch (e) {
    console.log("assignFeeToStudents error:", e);
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

module.exports = {
  createStudent,
  listStudents,
  getAdminOverview,
  setSemesterFee,
  assignFeeToStudents,
  markFee,
};
