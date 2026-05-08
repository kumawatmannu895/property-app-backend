const mongoose = require("mongoose");

const propertySchema = new mongoose.Schema({
  title: String,
  price: Number,
  location: String,
  images: [String],
  video: String,
  ownerId: String
}, { timestamps: true });

module.exports = mongoose.model("Property", propertySchema);