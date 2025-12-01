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
  const userId = req.user.userId || req.user.id;
  const { weight, bodyFat, gender, activityLevel, goal } = req.body;

  try {
    const client = new OpenAI({ apiKey: GITHUB_TOKEN, baseURL: endpoint });

    const response = await client.chat.completions.create({
      model,
      messages: [
        {
          role: "system",
          content: `
You are a nutrition planner. Output STRICT JSON ONLY with no comments, no extra keys, and no explanations.

The JSON MUST ALWAYS include non-null values for:
- "calories" (number)
- "macros" (object with numeric "protein", "carbohydrates", "fats")
- "mealPlans" (array with at least one entry, each having "meal" and a non-empty "items" array).

Example shape (structure only, values can change):
{
  "calories": 2500,
  "macros": { "protein": 180, "carbohydrates": 300, "fats": 60 },
  "mealPlans": [
    {
      "meal": "Breakfast",
      "items": [
        { "food": "Oatmeal", "calories": 150, "protein": 5, "carbohydrates": 27, "fat": 3 }
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
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

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

    return res.status(200).json({
      message: "✅ Nutrition plan saved successfully",
      nutritionPlan,
    });
  } catch (err) {
    console.log("❌ Nutrition plan error:", err);
    return res.status(500).json({ error: "Failed to generate nutrition plan" });
  }
});

// Get the latest saved nutrition plan for the authenticated user
router.get("/latest", authMiddleware, async (req, res) => {
  const userId = req.user.userId || req.user.id;

  try {
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const plans = user.nutritionPlans || [];
    if (!plans.length) {
      return res
        .status(404)
        .json({ error: "No nutrition plans found for this user" });
    }

    // Filter out any plans that have no mealPlans array or empty mealPlans
    const validPlans = plans.filter(
      (p) => Array.isArray(p.mealPlans) && p.mealPlans.length > 0
    );

    if (!validPlans.length) {
      return res.status(404).json({
        error: "No valid nutrition plans with mealPlans found for this user",
      });
    }

    // Sort by createdAt descending to get the most recent valid plan
    const latestPlan = validPlans
      .slice()
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))[0];

    return res.json({ latestPlan });
  } catch {
    return res.status(500).json({ error: "Failed to fetch nutrition plans" });
  }
});

export default router;
