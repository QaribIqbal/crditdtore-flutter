import mongoose from "mongoose";
import bcrypt from 'bcrypt';

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
  city: { type: String, required: true },
});
//Custom methods for the user database
UserSchema.pre('save',async function(next)
{
  if(!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password,10);
  return next();
})

//for caompring
UserSchema.methods.matchPassword= async function (enteredPassword)
{
  return await bcrypt.compare(enteredPassword,this.password);
}
const User = mongoose.model("User", UserSchema);
// module.exports = User;
export default User;
