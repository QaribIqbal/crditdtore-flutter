const mongoose = require("mongoose");

const SelectedCardSchema = new mongoose.Schema({
 // bankId: { type: mongoose.Schema.Types.ObjectId, ref: "Bank", required: true },
  //bankName: { type: String, required: true },
  cardId: { type: mongoose.Schema.Types.ObjectId, required:false },
 // cardName: { type: String, required: true },
  expiryDate: { type: Date, required: false },
});

const UserSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true }, // Store as hashed
  fullName: { type: String, required: true },
  mobileNumber: { type: String, required: true },
  selectedCards: [SelectedCardSchema], // Embedded documents
});

const User = mongoose.model("User", UserSchema);
module.exports = User;
