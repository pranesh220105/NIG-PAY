exports.getStudentDashboard = async (req, res) => {
  try {
    return res.status(200).json({
      name: "Student",
      totalFee: 50000,
      paidFee: 15000,
      pendingFee: 35000,
      message: "Dashboard loaded ✅",
    });
  } catch (err) {
    console.error("STUDENT DASHBOARD ERROR:", err);
    return res.status(500).json({ message: "Server error" });
  }
};
