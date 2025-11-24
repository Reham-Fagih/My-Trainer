import mongoose from "mongoose";

const predictionSchema = new mongoose.Schema({
  value: { type: Number, required: true },
  createdAt: { type: Date, default: Date.now },
});

const nutritionPlanSchema = new mongoose.Schema({
  activityLevel: { type: String, required: true },
  goal: { type: String, required: true },
  weight: { type: Number },
  bodyFat: { type: Number },
  gender: { type: String, enum: ["male", "female"] },
  calories: { type: Number },
  macros: {
    protein: { type: Number },
    fats: { type: Number },
    carbohydrates: { type: Number },
  },
  mealPlans: [
    {
      meal: { type: String },
      items: [
        {
          food: { type: String },
          calories: { type: Number },
          protein: { type: Number },
          carbohydrates: { type: Number },
          fat: { type: Number },
        },
      ],
    },
  ],
  createdAt: { type: Date, default: Date.now },
});

const userSchema = new mongoose.Schema({
  name: { type: String, required: false },
  email: { type: String, required: true, unique: true },
  phone: { type: String, required: true },
  password: { type: String, required: true },
  age: { type: Number, required: false },
  height: { type: Number, required: false },
  weight: { type: Number, required: false },
  gender: { type: String, enum: ["male", "female"], required: false },
  predictions: [predictionSchema],
  nutritionPlans: [nutritionPlanSchema],
}, { timestamps: true });

export default mongoose.model("User", userSchema);
