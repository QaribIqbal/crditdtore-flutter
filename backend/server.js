const express = require("express");
const cors = require("cors");  // Import the CORS middleware
const { MongoClient } = require("mongodb");

const app = express();
const uri = "mongodb://127.0.0.1:27017"; // MongoDB URI
const client = new MongoClient(uri);
let db;

// Use CORS middleware
app.use(cors());

async function connectDB() {
    try {
        await client.connect();
        db = client.db("flutter"); // Replace with your actual database name
        console.log("MongoDB Connected");
    } catch (error) {
        console.error("Failed to connect to MongoDB", error);
    }
}

connectDB();

app.get("/users", async (req, res) => {
    try {
        const users = await db.collection("users").find().toArray(); // 'users' is your collection name
        res.status(200).json(users); // Send the users as JSON
    } catch (error) {
        res.status(500).send({ error: "Failed to fetch users" });
    }
});

app.listen(3000, () => {
    console.log("Server running on http://localhost:3000");
});
