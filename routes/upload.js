const express = require("express");
const router = express.Router();
const multer = require("multer");
const { CloudinaryStorage } = require("multer-storage-cloudinary");
const cloudinary = require("cloudinary").v2;

// 👉 Cloudinary config
cloudinary.config({
  cloud_name: process.env.CLOUD_NAME,
  api_key: process.env.CLOUD_API_KEY,
  api_secret: process.env.CLOUD_API_SECRET,
});

// 👉 Storage (Cloudinary)
const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: "property_app", // 👈 folder name
    allowed_formats: ["jpg", "png", "jpeg", "webp"],
  },
});

const upload = multer({ storage });

// 👉 IMAGE UPLOAD
router.post("/image", upload.single("file"), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: "No file uploaded ❌" });
    }

    res.json({
      message: "Image uploaded to Cloudinary ✅",
      url: req.file.path, // 🔥 CLOUD URL
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 👉 VIDEO UPLOAD (optional)
router.post("/video", upload.single("file"), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: "No file uploaded ❌" });
    }

    res.json({
      message: "Video uploaded ✅",
      url: req.file.path,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;