const express = require("express");
const router = express.Router();
const db = require("../config/db");

router.get("/", async (req, res) => {

  try {

    const [rows] = await db.query(
      "SELECT * FROM users"
    );

    res.status(200).json(rows);

  } catch (err) {

    res.status(500).json({
      message: err.message
    });
  }
});

router.post("/", async (req, res) => {

  try {

    const { name, email } = req.body;

    await db.query(
      "INSERT INTO users(name,email) VALUES (?,?)",
      [name,email]
    );

    res.status(201).json({
      message: "User Created"
    });

  } catch (err) {

    res.status(500).json({
      message: err.message
    });
  }
});

module.exports = router;