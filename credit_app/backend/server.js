const mongoose = require("mongoose");
const express = require("express");
const cors = require("cors"); // Import the CORS middleware
const bankroute=require("./routes/banks.routes");
const userroute=require("./routes/banks.routes");
const app = express();

// MongoDB URI (You can also add credentials if needed)
const uri = "mongodb://127.0.0.1:27017/flutter"; // Directly using the DB name

// Use CORS middleware
app.use(cors());
app.use(express.json()); // Parse JSON bodies
// Mongoose connection
async function connectDB() {
    try {
        await mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true });
        console.log("MongoDB Connected");
    } catch (error) {
        console.error("Failed to connect to MongoDB", error);
    }
}

// Models
const Bank = require("./models/bank");
const User = require("./models/user");
const Discount = require("./models/discount");
const Category = require("./models/category");
//const bank_list = require("./controllers/banks.controller");

// Demo data to check
async function addBank() {
    const bank = new Bank({
        name: "Bank Al Habib",
        iconUrl: "assets/images/HBL_Logo.png",
        creditCards: [
            {
                name: "Platinum Card",
                cardType: "Credit",
                type: "Platinum",
                imageUrl: "assets/images/credit-card-gold.jpg",
            },
            {
                name: "Gold Card",
                cardType: "Credit",
                type: "Gold",
                imageUrl: "assets/images/blue-modern-credit-card.jpg",
            },
        ],
    });

    try {
        await bank.save();
        console.log("Bank saved successfully");
        console.log(bank);
    } catch (error) {
        console.error("Error saving bank", error);
    }
}
async function addUser() {
    const user = new User({
        fullName: "Ali",
        email: "example@gmail.com",
        password: "123456",
        mobileNumber: "03001234567",
}
)
try{
    await user.save();
    console.log("User saved successfully");
    console.log(user);
}
catch(e)
{
    console.error("Error saving user", e);
}
}

//Routes
app.use("/", bankroute);
app.use("/", userroute);
//APIS
//Get credit card list of selected bank
app.get("/:id", async (req, res) => {
    try {
        const bankId=req.params.id;
      
        const bank = await Bank.findById(bankId).select("creditCards");
        res.status(200).json(bank.creditCards);
    } catch (error) {
        res.status(500).send({ error: "Failed to fetch user" });
    }
});

//Save selected card of user

app.post("/users/:userId/cards", async (req, res) => {
const userId=req.params.userId;
    const {cardId, expiryDate}=req.body;
try{
    const user=await User.findById(userId);
    if(!user)
    {
        return res.status(404).send({error:"User not found"});
    }
     // Ensure expiryDate is in MM/YYYY format and convertionmg it to date format
      [month, year] = expiryDate.split('/');
      year='20'+year;
     const formattedExpiryDate = new Date(Date.UTC(year, month - 1)); // Use Date.UTC to avoid timezone issues
        user.selectedCards.push({ cardId, expiryDate: formattedExpiryDate });
     await user.save();
    res.status(200).send(user);
}
catch(e)
{
    res.status(500).send({error:"Failed to add card"});
}
});
app.get("/users/:userId/selectedcards", async (req, res) => {
    const userId = req.params.userId;

    try {
        // Fetch the user and their selected cards
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).send({ error: "User not found" });
        }

        const selectedCards = user.selectedCards;

        if (!selectedCards || selectedCards.length === 0) {
            return res.status(200).json([]);
        }

        // Extract card IDs from the user's selected cards
        const cardIds = selectedCards.map(card => card.cardId);

        // Find banks that have these card IDs in their creditCards array
        const banks = await Bank.find({ "creditCards.cardId": { $in: cardIds } });

        // Build response data
        const cardData = selectedCards.map(selectedCard => {
            const bank = banks.find(bank =>
                bank.creditCards.some(card => card.cardId.toString() === selectedCard.cardId.toString())
            );

            if (!bank) {
                return null; // Skip if bank or card not found
            }

            const card = bank.creditCards.find(card => card.cardId.toString() === selectedCard.cardId.toString());

            return {
                bankName: bank.name,
              //  bankIconUrl: bank.iconUrl || "", // Optional: Include bank icon if available
                cardId: selectedCard._id,
                cardName: card.name,
                cardType: card.cardType,
                cardTier: card.type,
                cardImageUrl: card.imageUrl || "",
                expiryDate: selectedCard.expiryDate ? selectedCard.expiryDate.toISOString().slice(0, 7) : null, // Format as MM/YYYY
            };
        }).filter(Boolean); // Remove any null values

        res.status(200).json(cardData);
    } catch (error) {
        console.error("Error fetching user cards:", error);
        res.status(500).send({ error: "Failed to fetch cards" });
    }
});
app.delete('/users/:userId/cards/:id', async (req, res) => {
    const cardId = req.params.id;
    const userId = req.params.userId;
    try {
      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).send({ error: "User not found" });
      }
  
      const result = await user.updateOne({ $pull: { selectedCards: { _id: cardId } } });
  
      if (result.nModified === 0) {
        return res.status(404).send({ error: "Card not found" });
      }
  
      res.status(200).send({ message: "Card deleted successfully" });
    } catch (e) {
      res.status(500).send({ error: "Failed to delete card" });
    }
  });
  

// Start the server
connectDB().then(() => {
   // addUser(); // Add bank on successful DB connection
    app.listen(3000, () => {
        console.log("Server running on http://localhost:3000");
    });
});
