const fs = require("fs");
const multer = require("multer");
const axios = require("axios");
const FormData = require("form-data");
const express = require("express");
const path = require("path");
const router = express.Router();
const authMiddleware = require("../middleware/auth");

const UPLOAD_DIR = path.join(__dirname, "../uploads");
if (!fs.existsSync(UPLOAD_DIR)) {
  fs.mkdirSync(UPLOAD_DIR);
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, UPLOAD_DIR);
  },
  filename: (req, file, cb) => cb(null, Date.now() + "-" + file.originalname),
});
const upload = multer({ storage });

router.post(
  "/predict",
  authMiddleware,
  upload.single("image"),
  async (req, res) => {
    if (!req.file) {
      return res.status(400).json({ error: "No image uploaded" });
    }

    const filePath = path.join(UPLOAD_DIR, req.file.filename);
    const userId = req.body.userId || (req.user && req.user.userId);

    if (!userId) {
      return res.status(400).json({ error: "userId is required" });
    }

    try {
      const formData = new FormData();
      formData.append("image", fs.createReadStream(filePath));

      const response = await axios.post(
        "http://127.0.0.1:5001/predict",
        formData,
        { headers: formData.getHeaders() }
      );

      const bfPercent = response.data.bfPercent;
      console.log(
        `[Node Server] Predicted BF% for user ${userId}: ${bfPercent}`
      );

      const User = require("../models/User");
      const user = await User.findById(userId);
      if (user) {
        user.predictions.push({ value: bfPercent });
        await user.save();
      }

      res.json({ bfPercent });
    } catch (err) {
      res.status(500).json({ error: err.message });
    } finally {
      if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
    }
  }
);

module.exports = router;
