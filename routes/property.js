const express = require("express");

const router = express.Router();

const Property = require("../models/Property");

const authMiddleware = require("../middleware/authMiddleware");


// 👉 ADD PROPERTY
router.post("/add", authMiddleware, async (req, res) => {

  try {

    const property = new Property({
      ...req.body,

      userId: req.userId,

      isApproved: false,

      isFeatured: false,

      isFavorite: false,
    });

    await property.save();

    res.json({
      message: "Property saved in DB ✅",
      data: property,
    });

  } catch (err) {

    res.status(500).json({
      error: err.message,
    });
  }
});


// 👉 GET ALL PROPERTIES
router.get("/", authMiddleware, async (req, res) => {

  try {

    const {
      search,
      minPrice,
      maxPrice,
    } = req.query;

    let filter = {
      userId: req.userId,
    };

    // 🔍 SEARCH
    if (search) {

      filter.title = {
        $regex: search,
        $options: "i",
      };
    }

    // 💰 PRICE FILTER
    if (minPrice || maxPrice) {

      filter.price = {};

      if (minPrice) {
        filter.price.$gte = Number(minPrice);
      }

      if (maxPrice) {
        filter.price.$lte = Number(maxPrice);
      }
    }

    const data = await Property.find(filter).sort({
      createdAt: -1,
    });

    res.json(data);

  } catch (error) {

    res.status(500).json({
      error: error.message,
    });
  }
});


// 👉 GET PROPERTY DETAILS
router.get("/:id", authMiddleware, async (req, res) => {

  try {

    const data = await Property.findOne({
      _id: req.params.id,
      userId: req.userId,
    });

    if (!data) {

      return res.status(404).json({
        message: "Not found ❌",
      });
    }

    res.json(data);

  } catch (error) {

    res.status(500).json({
      error: error.message,
    });
  }
});


// 👉 FAVORITE PROPERTY ❤️
router.put("/favorite/:id", authMiddleware, async (req, res) => {

  try {

    const property = await Property.findOne({
      _id: req.params.id,
      userId: req.userId,
    });

    if (!property) {

      return res.status(404).json({
        message: "Property not found ❌",
      });
    }

    property.isFavorite = !property.isFavorite;

    await property.save();

    res.json({
      message: "Favorite updated ❤️",
      data: property,
    });

  } catch (error) {

    res.status(500).json({
      error: error.message,
    });
  }
});


// 👉 DELETE PROPERTY
router.delete("/delete/:id", authMiddleware, async (req, res) => {

  try {

    const deleted = await Property.findOneAndDelete({
      _id: req.params.id,
      userId: req.userId,
    });

    if (!deleted) {

      return res.status(404).json({
        message: "Property not found ❌",
      });
    }

    res.json({
      message: "Property deleted successfully ✅",
    });

  } catch (error) {

    res.status(500).json({
      error: error.message,
    });
  }
});


// 👉 UPDATE PROPERTY
router.put("/update/:id", authMiddleware, async (req, res) => {

  try {

    const updated = await Property.findOneAndUpdate(
      {
        _id: req.params.id,
        userId: req.userId,
      },

      req.body,

      {
        new: true,
      }
    );

    if (!updated) {

      return res.status(404).json({
        message: "Property not found ❌",
      });
    }

    res.json({
      message: "Property updated ✅",
      data: updated,
    });

  } catch (error) {

    res.status(500).json({
      error: error.message,
    });
  }
});


// 👉 ADMIN APPROVE PROPERTY
router.put("/approve/:id", async (req, res) => {

  try {

    const updated = await Property.findByIdAndUpdate(
      req.params.id,

      {
        isApproved: true,
      },

      {
        new: true,
      }
    );

    res.json({
      message: "Property approved ✅",
      data: updated,
    });

  } catch (error) {

    res.status(500).json({
      error: error.message,
    });
  }
});


module.exports = router;