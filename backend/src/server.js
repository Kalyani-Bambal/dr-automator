require("dotenv").config();

const express = require("express");
const cors = require("cors");

const app = express();

const userRoutes = require("./routes/users");

app.use(cors());
app.use(express.json());

app.get("/", (req,res) => {

  res.json({
    application: "DR Automator",
    status: "running"
  });

});

app.get("/health",(req,res) => {

  res.status(200).json({
    status: "healthy",
    region: process.env.AWS_REGION,
    timestamp: new Date()
  });

});

app.use("/users", userRoutes);

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {

  console.log(
    `Server running on port ${PORT}`
  );

});