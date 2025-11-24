import express from "express";
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

export default router;
