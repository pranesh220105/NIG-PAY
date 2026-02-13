const express = require("express");
const cors = require("cors");

const authRoutes = require("./routes/auth.routes");
const studentRoutes = require("./routes/student.routes");

const app = express();

app.use(cors({ origin: "*" }));
app.use(express.json());

app.get("/", (req, res) => res.send("Backend running ✅"));

app.use("/auth", authRoutes);
app.use("/api/student", studentRoutes);

module.exports = app;
