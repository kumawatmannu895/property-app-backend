const mongoose = require("mongoose");

const connectDB = async () => {
  try {
    const url = "mongodb://manoj:8239432695@ac-jlfjft4-shard-00-00.lx0xxfn.mongodb.net:27017,ac-jlfjft4-shard-00-01.lx0xxfn.mongodb.net:27017,ac-jlfjft4-shard-00-02.lx0xxfn.mongodb.net:27017/propertyDB?ssl=true&replicaSet=atlas-o19gic-shard-0&authSource=admin&retryWrites=true&w=majority";

    console.log("Connecting to MongoDB...");

    await mongoose.connect(url);

    console.log("MongoDB Connected ✅");
  } catch (error) {
    console.error("DB Error:", error.message);
    process.exit(1);
  }
};

module.exports = connectDB;