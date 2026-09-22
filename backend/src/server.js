require("dotenv").config();

const express = require("express");
const client = require("prom-client");
const cors = require("cors");
const db = require("./config/db");

const userRoutes = require("./routes/users");

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Root endpoint
app.get("/", (req, res) => {
  res.json({
    application: "DR Automator",
    status: "running"
  });
});

// Health endpoint
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "healthy",
    region: process.env.AWS_REGION || "unknown",
    timestamp: new Date().toISOString()
  });
});

// User routes
app.use("/users", userRoutes);

// Prometheus metrics
client.collectDefaultMetrics();

app.get("/metrics", async (req, res) => {
  try {
    res.set("Content-Type", client.register.contentType);

    const metrics = await client.register.metrics();

    res.end(metrics);
  } catch (err) {
    console.error("❌ Failed to generate metrics:", err);
    res.status(500).end();
  }
});

// Server configuration
const PORT = process.env.PORT || 5000;

async function waitForDatabase(attempt = 1, maxAttempts = 30) {
  try {
    await db.query("SELECT 1");
    console.log("✅ Connected to MySQL");
    return true;
  } catch (err) {
    if (attempt >= maxAttempts) {
      throw err;
    }

    console.warn(`⚠️ MySQL not ready yet (attempt ${attempt}/${maxAttempts}); retrying in 2s...`);
    await new Promise((resolve) => setTimeout(resolve, 2000));
    return waitForDatabase(attempt + 1, maxAttempts);
  }
}

// Start server after DB connection
async function startServer() {
  try {
    await waitForDatabase();

    app.listen(PORT, () => {
      console.log(`🚀 DR Automator backend running on port ${PORT}`);
      console.log(`📊 Metrics available at http://localhost:${PORT}/metrics`);
      console.log(`❤️ Health check: http://localhost:${PORT}/health`);
    });
  } catch (err) {
    console.error("❌ Database connection failed after retries");
    console.error(err);

    process.exit(1);
  }
}

startServer();