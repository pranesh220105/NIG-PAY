const express = require("express");
const router = express.Router();

// ✅ Correct import
const authController = require("../controllers/auth.controller");

// ✅ These MUST exist now
router.post("/register", authController.register);
router.post("/login", authController.login);

module.exports = router;
