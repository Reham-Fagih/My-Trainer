import express from "express";
import OpenAI from "openai";
import dotenv from "dotenv";
import User from "../models/User.js";
import authMiddleware from "../middleware/auth.js";
dotenv.config();

const router = express.Router();

const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const endpoint = "https://models.github.ai/inference";
const model = "openai/gpt-4o-mini";

router.post("/", authMiddleware, async (req, res) => {
  const { environment, duration, weight, height, bodyFat } = req.body;
  const userId = req.user.id;

  try {
    const client = new OpenAI({ apiKey: GITHUB_TOKEN, baseURL: endpoint });

    const response = await client.chat.completions.create({
      model,
      messages: [
        {
          role: "system",
          content:
            "You are a fitness coach. Generate a workout plan based on user stats and preferences. Output JSON only with 'durationWeeks', 'environment', and an array of 'weeklyPlans', each containing 'day' and 'exercises'.",
        },
        {
          role: "user",
          content: JSON.stringify({
            environment,
            duration,
            weight,
            height,
            bodyFat,
          }),
        },
      ],
    });

    const output = response.choices[0].message.content;
    const workoutPlan = JSON.parse(output);

    const user = await User.findById(userId);
    user.workoutPlans.push(workoutPlan);
    await user.save();

    return res.json({
      message: "Workout plan saved successfully ✅",
      savedPlan: workoutPlan,
    });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

export default router;
