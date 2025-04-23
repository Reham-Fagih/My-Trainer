const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
require("dotenv").config();
console.log("MONGODB_URI is:", process.env.MONGODB_URI);

const app = express();
app.use(cors());
app.use(express.json());

mongoose
  .connect(process.env.MONGODB_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("✅ Connected to MongoDB"))
  .catch((err) => console.error("❌ MongoDB connection error:", err));

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  phone: { type: String, required: true },
  password: { type: String, required: true },
});
const User = mongoose.model("User", userSchema);

app.post("/signup", async (req, res) => {
  const { email, phone, password } = req.body;

  try {
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      console.log("User already exists: ", email);
      return res.status(400).json({ msg: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const newUser = new User({
      email,
      phone,
      password: hashedPassword,
    });

    await newUser.save();
    console.log("User created successfully:", newUser);

    res.status(201).json({ msg: "User created successfully" });
  } catch (err) {
    console.error("Error during sign-up:", err.message);
    res.status(500).json({ error: err.message });
  }
});

app.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });
    if (!user) return res.status(401).json({ message: "Invalid credentials" });

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(401).json({ message: "Invalid credentials" });

    const token = jwt.sign(
      { userId: user._id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );

    console.log("Login successful for user:", email);
    return res.status(200).json({ message: "Login successful", token });
  } catch (err) {
    console.error("Error during login:", err.message);
    return res.status(500).json({ message: "Error logging in" });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
