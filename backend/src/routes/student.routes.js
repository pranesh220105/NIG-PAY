const express = require("express");
const router = express.Router();

// ✅ Correct path (routes folder -> controllers folder)
const { getStudentDashboard } = require("../controllers/student.controller");

// ✅ GET /api/student/dashboard
router.get("/dashboard", getStudentDashboard);

module.exports = router;
