import express from "express";
import mongoose from "mongoose";
import User from "../models/User.js";
import { validateMealplan } from "../middleware/validateFields.js";

const router = express.Router();

router.get("/user/:email", async (req, res) => {
  try {
    const user = await User.findOne({ email: req.params.email });
    if (!user) return res.status(404).json({ message: "User not found" });
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: "Error fetching user", error });
  }
});

router.put("/user/:email", async (req, res) => {
  try {
    const updatedUser = await User.findOneAndUpdate(
      { email: req.params.email },
      req.body,
      { new: true }
    );
    if (!updatedUser)
      return res.status(404).json({ message: "User not found" });
    res.json(updatedUser);
  } catch (error) {
    res.status(500).json({ message: "Error updating profile", error });
  }
});

router.post("/user/:email/nutrition", validateMealplan, async (req, res) => {
  const { email } = req.params;
  const planData = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: "User not found" });

    user.nutritionPlans = user.nutritionPlans || [];
    user.nutritionPlans.push(planData);

    await user.save();

    res.status(200).json({ message: "Nutrition plan saved successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
});

router.post("/user/:email/workout", async (req, res) => {
  const { email } = req.params;
  const workoutData = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) return res.status(404).json({ message: "User not found" });

    user.workoutPlans = user.workoutPlans || [];
    user.workoutPlans.push(workoutData);

    await user.save();

    res.status(200).json({ message: "Workout plan saved successfully" });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: "Server error" });
  }
});

// Increment user totalPoints by a given amount
router.post("/user/:id/points", async (req, res) => {
  console.log("/user/:id/points body:", req.body);

  const { id } = req.params;
  const { points } = req.body || {};

  // Basic validation
  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).json({ message: "Invalid user ID" });
  }

  const pointsNumber = Number(points);
  if (!Number.isFinite(pointsNumber) || pointsNumber <= 0) {
    return res
      .status(400)
      .json({ message: "'points' must be a positive number" });
  }

  try {
    const updatedUser = await User.findByIdAndUpdate(
      id,
      { $inc: { totalPoints: pointsNumber } },
      { new: true }
    );

    if (!updatedUser) {
      return res.status(404).json({ message: "User not found" });
    }

    return res.status(200).json(updatedUser);
  } catch (error) {
    console.error("Error updating user points", error);
    return res.status(500).json({ message: "Server error", error });
  }
});

// Get leaderboard of users sorted by totalPoints (desc)
router.get("/users/leaderboard", async (req, res) => {
  const { limit } = req.query;

  let parsedLimit = Number(limit);
  if (!Number.isFinite(parsedLimit) || parsedLimit <= 0) {
    // Default limit if not provided or invalid
    parsedLimit = 50;
  }

  try {
    const users = await User.find()
      .sort({ totalPoints: -1 })
      .limit(parsedLimit)
      .select("name email totalPoints");

    return res.status(200).json(
      users.map(u => ({
        name: u.name && u.name.trim() !== "" 
            ? u.name              
            : u.email.split("@")[0], 
        email: u.email,
        totalPoints: u.totalPoints
      }))
    );

  } catch (error) {
    console.error("Error fetching leaderboard", error);
    return res.status(500).json({ message: "Server error", error });
  }
});

export default router;
