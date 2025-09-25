export function validateMealplan(req, res, next) {
  const { weight, bodyFat, gender, activityLevel, goal } = req.body;

  if (!weight || !bodyFat || !gender || !activityLevel || !goal) {
    return res.status(400).json({ error: "Missing required fields" });
  }
  next();
}

export function validateWorkout(req, res, next) {
  const { environment, duration, weight, height, bodyFat } = req.body;

  if (!environment || !duration || !weight || !height || !bodyFat) {
    return res.status(400).json({ error: "Missing required fields" });
  }
  next();
}
