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
  const userId = req.user.userId; // JWT payload has { userId: user._id }

  try {
    const client = new OpenAI({ apiKey: GITHUB_TOKEN, baseURL: endpoint });

    const response = await client.chat.completions.create({
      model,
      messages: [
        {
          role: "system",
          content:
            "You are a structured JSON API for workout planning. Always respond with VALID JSON only, no markdown or explanations. The JSON MUST have exactly this shape: { 'durationWeeks': number, 'environment': string, 'weeklyPlans': [ { 'day': string, 'exercises': [ { 'name': string, 'sets': number, 'reps': number | null, 'duration': string | null } ] } ] }. Always include at least 3 weeklyPlans entries and at least 3 exercises per day. If something is unknown, still include the field and use a reasonable default (e.g., null or '-').",
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

    // Debug log to inspect the generated workout plan structure
    console.log(
      "Generated workout plan JSON:",
      JSON.stringify(workoutPlan, null, 2)
    );

    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ error: "User not found for provided token" });
    }

    if (!Array.isArray(user.workoutPlans)) {
      user.workoutPlans = [];
    }

    user.workoutPlans.push(workoutPlan);
    await user.save();

    return res.json({
      message: "Workout plan saved successfully ✅",
      savedPlan: workoutPlan,
    });
  } catch (err) {
    console.error("Error in workoutPlan route:", err);
    return res.status(500).json({ error: err.message });
  }
});

export default router;
