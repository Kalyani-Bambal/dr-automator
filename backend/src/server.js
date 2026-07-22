require("dotenv").config();

const express = require("express");
const cors = require("cors");
const db = require("./db");   // <-- import db

const app = express();

const userRoutes = require("./routes/users");

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.json({
    application: "DR Automator",
    status: "running"
  });
});

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    region: process.env.AWS_REGION,
    timestamp: new Date()
  });
});

app.use("/users", userRoutes);

const db = require("./db");

const PORT = process.env.PORT || 5000;

async function startServer() {
  try {
    await db.query("SELECT 1");
    console.log("✅ Connected to MySQL");

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  } catch (err) {
    console.error("❌ Database connection failed");
    console.error(err);
    process.exit(1);
  }
}

startServer();