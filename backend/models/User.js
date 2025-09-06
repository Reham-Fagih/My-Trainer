const mongoose = require("mongoose");

const predictionSchema = new mongoose.Schema({
  value: { type: Number, required: true },
  createdAt: { type: Date, default: Date.now },
});

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  phone: { type: String, required: true },
  password: { type: String, required: true },
  predictions: [predictionSchema],
});

module.exports = mongoose.model("User", userSchema);
