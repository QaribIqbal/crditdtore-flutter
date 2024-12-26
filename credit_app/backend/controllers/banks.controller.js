const Bank = require("../models/bank");
const User = require("../models/user");
const bank_list = async (req, res) => {
    try {
        const banks = await Bank.find();
        res.status(200).json(banks);
    }
    catch (e) {
        res.status(500).send({ e: "Failed to fetch banks" });
    }
};

const user_list =async (req, res) => {
    try {
        const users = await User.find(); // Using Mongoose for querying
        res.status(200).json(users); // Send the users as JSON
    } catch (error) {
        res.status(500).send({ error: "Failed to fetch users" });
    }
};
const creditCard_list = async (req, res) => {

};
module.exports = {
    bank_list,
    user_list,
};