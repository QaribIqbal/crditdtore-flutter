const mongoose = require("mongoose");

const CreditCardSchema = new mongoose.Schema({
  cardId: { type: mongoose.Schema.Types.ObjectId, auto: true },
  name: { type: String, required: true },
  cardType: { type: String, required: true },
  type: { type: String, required: true }, // e.g., Platinum, Gold
  imageUrl: { type: String, required: false },
});

const BankSchema = new mongoose.Schema({
  name: { type: String, required: true },
  iconUrl: { type: String, required: false },
 // imageUrl: { type: String, required: false },
  creditCards: [CreditCardSchema], // Embedded documents
});

const Bank = mongoose.model("Bank", BankSchema);
module.exports = Bank;
