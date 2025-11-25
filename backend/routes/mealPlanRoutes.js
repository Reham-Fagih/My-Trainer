import express from "express";
import OpenAI from "openai";
import dotenv from "dotenv";
import authMiddleware from "../middleware/auth.js";
import User from "../models/User.js";
dotenv.config();

const router = express.Router();

const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const endpoint = "https://models.github.ai/inference";
const model = "openai/gpt-4o-mini";

router.post("/", authMiddleware, async (req, res) => {
  const userId = req.user.id;
  const { weight, bodyFat, gender, activityLevel, goal } = req.body;

  try {
    const client = new OpenAI({ apiKey: GITHUB_TOKEN, baseURL: endpoint });

    const response = await client.chat.completions.create({
      model,
      messages: [
        {
          role: "system",
          content: `
You are a nutrition planner. Output strict JSON only:
{
  "calories": number,
  "macros": { "protein": number, "carbohydrates": number, "fats": number },
  "mealPlans": [
    {
      "meal": "string",
      "items": [
        { "food": "string", "calories": number, "protein": number, "carbohydrates": number, "fat": number }
      ]
    }
  ]
}
`.trim(),
        },
        {
          role: "user",
          content: JSON.stringify({
            weight,
            bodyFat,
            gender,
            activityLevel,
            goal,
          }),
        },
      ],
    });

    const output = response.choices[0].message.content;
    const nutritionPlan = JSON.parse(output);

    const user = await User.findById(userId);
    user.nutritionPlans.push({
      activityLevel,
      goal,
      weight,
      bodyFat,
      gender,
      calories: nutritionPlan.calories,
      macros: nutritionPlan.macros,
      mealPlans: nutritionPlan.mealPlans,
    });

    await user.save();

    return res.status(201).json({
      message: "✅ Nutrition plan saved successfully",
      nutritionPlan,
    });
  } catch (err) {
    console.log("❌ Nutrition plan error:", err);
    return res.status(500).json({ error: "Failed to generate nutrition plan" });
  }
});

router.get("/", authMiddleware, async (req, res) => {
  const userId = req.user.id;

  try {
    const user = await User.findById(userId);
    return res.json(user.nutritionPlans);
  } catch {
    return res.status(500).json({ error: "Failed to fetch nutrition plans" });
  }
});

export default router;
