import express from "express";
import OpenAI from "openai";
import dotenv from "dotenv";
dotenv.config();

const router = express.Router();

const GITHUB_TOKEN = process.env.GITHUB_TOKEN;
const endpoint = "https://models.github.ai/inference";
const model = "openai/gpt-4o-mini";

router.post("/", async (req, res) => {
  const { environment, duration, weight, height, bodyFat } = req.body;

  try {
    const client = new OpenAI({ apiKey: GITHUB_TOKEN, baseURL: endpoint });

    const response = await client.chat.completions.create({
      model,
      messages: [
        {
          role: "system",
          content:
            "You are a fitness coach. Generate a workout plan based on user stats and preferences. Output JSON only with 'durationWeeks', 'environment', and an array of 'weeklyPlans', each containing 'day' and 'exercises'. Keep exercises realistic for gym or home settings.",
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

    try {
      const workoutPlan = JSON.parse(output);
      res.json(workoutPlan);
    } catch {
      res.status(500).json({ error: "Invalid JSON from model", raw: output });
    }
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
