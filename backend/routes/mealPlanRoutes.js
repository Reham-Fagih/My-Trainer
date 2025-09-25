import express from "express";
import OpenAI from "openai";
import dotenv from "dotenv";
dotenv.config();

const router = express.Router();

const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const endpoint = "https://models.github.ai/inference";
const model = "openai/gpt-4o-mini";

router.post("/", async (req, res) => {
  const { weight, bodyFat, gender, activityLevel, goal } = req.body;

  try {
    const client = new OpenAI({ apiKey: GITHUB_TOKEN, baseURL: endpoint });

    const response = await client.chat.completions.create({
      model,
      messages: [
        {
          role: "system",
          content: `
You are a nutrition planner. Output the response as strict JSON only.
- The top-level object must contain: calories (number), macros (object), mealPlans (array).
- macros object contains: protein, carbohydrates, fats (all numbers in grams, no units).
- mealPlans is an array of meals; each meal has:
    - meal (string)
    - items (array)
        - each item has food (string), calories (number), protein (number), carbohydrates (number), fat (number)
- Do NOT include any text outside the JSON.
- Example response:
{
  "calories": 2200,
  "macros": { "protein": 150, "carbohydrates": 200, "fats": 70 },
  "mealPlans": [
    {
      "meal": "Breakfast",
      "items": [
        { "food": "Scrambled eggs", "calories": 210, "protein": 18, "carbohydrates": 1, "fat": 15 }
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

    try {
      const mealPlan = JSON.parse(output);
      res.json(mealPlan);
    } catch (e) {
      res.status(500).json({ error: "Invalid JSON from model", raw: output });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
