import express from "express";
import mongoose from "mongoose";
import cors from "cors";
import dotenv from "dotenv";
dotenv.config();

import authRoutes from "./routes/authRoutes.js";
import predictRoutes from "./routes/predictRoutes.js";
import mealPlanRoutes from "./routes/mealPlanRoutes.js";
import workoutPlanRoutes from "./routes/workoutPlanRoutes.js";
import userRoutes from "./routes/userRoutes.js";
import {
  validateMealplan,
  validateWorkout,
} from "./middleware/validateFields.js";

const app = express();

// Global middleware FIRST
app.use(cors());
app.use(express.json());

// Request logger
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

// Routes
app.use("/api", userRoutes);
app.use("/", authRoutes);
app.use("/", predictRoutes);
app.use("/api/mealplan", mealPlanRoutes);
app.use("/api/workoutplan", workoutPlanRoutes);
app.use("/api/mealplan", validateMealplan, mealPlanRoutes);
app.use("/api/workoutplan", validateWorkout, workoutPlanRoutes);

app.get("/ping", (req, res) => {
  res.send("pong");
});

mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => console.log("✅ Connected to MongoDB"))
  .catch((err) => console.error("❌ MongoDB connection error:", err));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
