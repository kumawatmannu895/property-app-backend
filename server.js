require("dotenv").config(); // 🔥 सबसे पहले

// 🔴 ERROR HANDLER
process.on("uncaughtException", (err) => {
  console.log("UNCAUGHT EXCEPTION:");
  console.log(err);
});

process.on("unhandledRejection", (err) => {
  console.log("UNHANDLED REJECTION:");
  console.log(err);
});

console.log("MONGO_URI:", process.env.MONGO_URI); // 🔍 DEBUG

const express = require("express");
const cors = require("cors");

const connectDB = require("./config/db");

// 👉 ROUTES
const authRoute = require("./routes/auth");
const uploadRoute = require("./routes/upload");
const propertyRoute = require("./routes/property");

console.log("SERVER FILE RUNNING ✅");

const app = express();

// 👉 DB CONNECT
connectDB();

// 👉 MIDDLEWARE
app.use(cors());
app.use(express.json());

// 👉 STATIC
app.use("/uploads", express.static("uploads"));

// 👉 ROUTES
app.use("/auth", authRoute);
app.use("/upload", uploadRoute);
app.use("/property", propertyRoute);

// 👉 TEST
app.get("/", (req, res) => {
  res.send("API Running 🚀");
});

app.get("/check", (req, res) => {
  res.send("CHECK OK 🚀");
});

// 👉 PORT
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});