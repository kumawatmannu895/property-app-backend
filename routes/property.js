const express = require("express");
const router = express.Router();
const Property = require("../models/Property");
const authMiddleware = require("../middleware/authMiddleware");

// 👉 ADD Property (SECURE + USER LINKED)
router.post("/add", authMiddleware, async (req, res) => {
  try {
    const property = new Property({
      ...req.body,
      userId: req.userId, // 🔥 token से userId
    });

    await property.save();

    res.json({
      message: "Property saved in DB ✅",
      data: property,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// 👉 GET ALL (ONLY USER DATA 🔐)
router.get("/", authMiddleware, async (req, res) => {
  try {
    const data = await Property.find({ userId: req.userId }).sort({
      createdAt: -1,
    });

    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 👉 GET BY ID (ONLY OWN PROPERTY)
router.get("/:id", authMiddleware, async (req, res) => {
  try {
    const data = await Property.findOne({
      _id: req.params.id,
      userId: req.userId,
    });

    if (!data) {
      return res.status(404).json({ message: "Not found ❌" });
    }

    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 👉 DELETE (ONLY OWN PROPERTY 🔥)
router.delete("/delete/:id", authMiddleware, async (req, res) => {
  try {
    const deleted = await Property.findOneAndDelete({
      _id: req.params.id,
      userId: req.userId,
    });

    if (!deleted) {
      return res.status(404).json({ message: "Property not found ❌" });
    }

    res.json({ message: "Property deleted successfully ✅" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 👉 UPDATE (ONLY OWN PROPERTY ✏️)
router.put("/update/:id", authMiddleware, async (req, res) => {
  try {
    const updated = await Property.findOneAndUpdate(
      {
        _id: req.params.id,
        userId: req.userId,
      },
      req.body,
      { new: true }
    );

    if (!updated) {
      return res.status(404).json({ message: "Property not found ❌" });
    }

    res.json({
      message: "Property updated ✅",
      data: updated,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;