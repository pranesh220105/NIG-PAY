const router = require("express").Router();
const { auth, requireRole } = require("../middleware/auth.middleware");
const { createFee, getMyFees, getAllFees } = require("../controllers/fee.controller");

// ADMIN creates fee for a student
router.post("/", auth, requireRole("ADMIN"), createFee);

// Student sees only his fees
router.get("/me", auth, getMyFees);

// ADMIN can see all fees
router.get("/", auth, requireRole("ADMIN"), getAllFees);

module.exports = router;
