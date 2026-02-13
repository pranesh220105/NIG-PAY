const router = require("express").Router();
const { auth, requireRole } = require("../middleware/auth.middleware");
const { addFeeByStudentEmail } = require("../controllers/fee.controller");
const { createStudent, setSemesterFee, markFee } = require("../controllers/admin.controller");

router.post("/fee/add", auth, requireRole("ADMIN"), addFeeByStudentEmail);
router.post("/students", auth, requireRole("ADMIN"), createStudent);
router.post("/fee/semester", auth, requireRole("ADMIN"), setSemesterFee);
router.post("/fee/mark", auth, requireRole("ADMIN"), markFee);

module.exports = router;
