const mongoose = require("mongoose");
const express = require("express");
const cors = require("cors"); // Import the CORS middleware
const bankroute = require("./routes/banks.routes");
const userroute = require("./routes/banks.routes");
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
async function add_Category() {
    //let category:Category;
    const category = [{
        name: "Health and Wellness",
    },
    {
        name: "Food and Dining",
    },
    {
        name: "Travel and Accommodation",
    },
    {
        name: "Shopping and Retail",
    },
    {
        name: "Entertainment",
    },
    {
        name: "Beauty and Personal Care",
    },
    {
        name: "Education and Learning",
    },
    {
        name: "Automotive",
    },
    {
        name: "Pet Care",
    }];
    try {
        await Category.insertMany(category);
        console.log("Category saved successfully");
    }
    catch (e) {
        console.error("Error saving category", e);
    }
};
async function addUser() {
    const user = new User({
        fullName: "Ali",
        email: "example@gmail.com",
        password: "123456",
        mobileNumber: "03001234567",
    }
    )
    try {
        await user.save();
        console.log("User saved successfully");
        console.log(user);
    }
    catch (e) {
        console.error("Error saving user", e);
    }
}
async function addOffers() {
    const offer = [
        {
            "name": "Holiday Special - Cafe Delight",
            "discountPercentage": 20,
            "startDate": "2024-12-20T00:00:00Z",
            "endDate": "2025-01-05T23:59:59Z",
            "description": "Get 20% off on all menu items during the holiday season.",
            "category": ["676ebeac416f24332abd76ab"], // Replace with actual category ObjectId
            "location": {
                "name": "Cafe Delight",
                "address": "123 Main Street",
                "city": "Lahore"
            },
            "eligibleCards": [
                { "cardId": "676980b7202301f66242efd5" },
                { "cardId": "676980b7202301f66242efd5" }
            ]
        },
        {
            "name": "Fitness Club Year-End Offer",
            "discountPercentage": 30,
            "startDate": "2024-12-15T00:00:00Z",
            "endDate": "2024-12-31T23:59:59Z",
            "description": "Enjoy 30% off on annual memberships.",
            "category": ["676ebeac416f24332abd76aa"], // Replace with actual category ObjectId
            "location": {
                "name": "Health & Wellness Gym",
                "address": "456 Elm Street",
                "city": "Karachi"
            },
            "eligibleCards": [
                { "cardId": "676980b7202301f66242efd7" }
            ]
        },
        {
            "name": "Luxury Hotel Winter Deal",
            "discountPercentage": 25,
            "startDate": "2024-12-01T00:00:00Z",
            "endDate": "2025-01-31T23:59:59Z",
            "description": "25% off on luxury suites for the winter season.",
            "category": ["676ebeac416f24332abd76ac"], // Replace with actual category ObjectId
            "location": {
                "name": "Grand Plaza Hotel",
                "address": "789 Maple Avenue",
                "city": "Islamabad"
            },
            "eligibleCards": [
                { "cardId": "676980b7202301f66242efd5" }
            ]
        },
        {
            "name": "Tech Store New Year Sale",
            "discountPercentage": 15,
            "startDate": "2025-01-01T00:00:00Z",
            "endDate": "2025-01-10T23:59:59Z",
            "description": "15% off on electronics and gadgets.",
            "category": ["676ebeac416f24332abd76ad"], // Replace with actual category ObjectId
            "location": {
                "name": "Tech World",
                "address": "101 Tech Park",
                "city": "Faisalabad"
            },
            "eligibleCards": [
                { "cardId": "676980b7202301f66242efd5" }
            ]
        }
    ]
    try {
        await Discount.insertMany(offer);
        console.log("Offers added successfully!");
    }
    catch (e) {
        console.log("Offers cant be added", e);
    }
};
//Routes
app.use("/", bankroute);
app.use("/", userroute);
//APIS
//Get credit card list of selected bank
app.get("/:id", async (req, res) => {
    try {
        const bankId = req.params.id;

        const bank = await Bank.findById(bankId).select("creditCards");
        res.status(200).json(bank.creditCards);
    } catch (error) {
        res.status(500).send({ error: "Failed to fetch user" });
    }
});

//Save selected card of user

app.post("/users/:userId/cards", async (req, res) => {
    const userId = req.params.userId;
    const { cardId, expiryDate } = req.body;
    try {
        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).send({ error: "User not found" });
        }
        // Ensure expiryDate is in MM/YYYY format and convertionmg it to date format
        [month, year] = expiryDate.split('/');
        year = '20' + year;
        const formattedExpiryDate = new Date(Date.UTC(year, month - 1)); // Use Date.UTC to avoid timezone issues
        user.selectedCards.push({ cardId, expiryDate: formattedExpiryDate });
        await user.save();
        res.status(200).send(user);
    }
    catch (e) {
        res.status(500).send({ error: "Failed to add card" });
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
//Categories fetched
app.get('/categories/category', async (req, res) => {
    try {
        const categories = await Category.find().sort({ name: 1 }); // Sort categories alphabetically by name
        if (categories.length === 0) {
            return res.status(200).json({ message: "No categories found" });
        }
        res.status(200).json({ categories });
    } catch (e) {
        console.error("Error fetching categories:", e);
        res.status(500).send({ error: "Failed to fetch categories" });
    }
});

//Fetching And filtering offers
// app.get('/discounts/offers?category=type&location=city&card=id1,id2,id3', async (req, res) => {
    app.get('/discounts/offers', async (req, res) => {
    const { category, location, card } = req.query;
    const query={};
    if(category)
    {
  //   query.category=category;
  query.category= await Category.findOne({name:category}).select('_id');    
}
    if(location)
        {
         query["location.city"]=location;
        }
        if(card)
        {
            const cardIds=card.split(',');
         query["eligibleCards.cardId"]={$in:cardIds};
        }
    try {
       const offers= await Discount.find(query);
       res.status(200).json(offers);
    }
    catch (e) {
  res.status(500).json({message: e.message});
    }

});

// Start the server
connectDB().then(() => {
    // addOffers(); // Add bank on successful DB connection
    app.listen(3000, () => {
        console.log("Server running on http://localhost:3000");
    });
});
