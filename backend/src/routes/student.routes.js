const express = require("express");
const router = express.Router();
const { auth } = require("../middleware/auth.middleware");
const {
  getStudentDashboard,
  getStudentPayments,
  makePayment,
} = require("../controllers/student.controller");

router.get("/dashboard", auth, getStudentDashboard);
router.get("/payments", auth, getStudentPayments);
router.post("/pay", auth, makePayment);

module.exports = router;
