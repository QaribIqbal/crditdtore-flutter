//const category=require("./category");
//const mongoose = require("mongoose");
import mongoose from "mongoose";


const LocationSchema = new mongoose.Schema({
  name: { type: String, required: true },
  address: { type: String, required: true },
  city: { type: String, required: true },
  
});

const EligibleCardSchema = new mongoose.Schema({
  cardId: { type: mongoose.Schema.Types.ObjectId, ref: "Banks.creditCards", required: true },
 // cardName: { type: String, required: true },
});

const DiscountSchema = new mongoose.Schema({
  name: { type: String, required: true },
  discountPercentage: { type: Number, required: true },
  startDate: { type: Date, required: true },
  endDate: { type: Date, required: true },
  description: { type: String, required: false },
  category: [{type: mongoose.Schema.Types.ObjectId , ref: "categories"}], // e.g., Hotel, Cafe
  location: LocationSchema, // Embedded document
  eligibleCards: [EligibleCardSchema], // Array of references
});

const Discount = mongoose.model("Discount", DiscountSchema);
// module.exports = Discount;
export default Discount;
