const router = require("express").Router();
const { auth, requireRole } = require("../middleware/auth.middleware");
const { addFeeByStudentEmail } = require("../controllers/fee.controller");
const {
  createStudent,
  listStudents,
  getAdminOverview,
  setSemesterFee,
  assignFeeToStudents,
  markFee,
} = require("../controllers/admin.controller");

router.post("/fee/add", auth, requireRole("ADMIN"), addFeeByStudentEmail);
router.get("/overview", auth, requireRole("ADMIN"), getAdminOverview);
router.get("/students", auth, requireRole("ADMIN"), listStudents);
router.post("/students", auth, requireRole("ADMIN"), createStudent);
router.post("/fee/semester", auth, requireRole("ADMIN"), setSemesterFee);
router.post("/fee/bulk", auth, requireRole("ADMIN"), assignFeeToStudents);
router.post("/fee/mark", auth, requireRole("ADMIN"), markFee);

module.exports = router;
