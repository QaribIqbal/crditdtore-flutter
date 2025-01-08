// const User = require('../models/user');
// const jwt = require('jsonwebtoken');
import User from '../models/user.js';
import jwt from 'jsonwebtoken';

//Function for generating token 
//id is a payload
const generateToken = (id) => {
    return jwt.sign({ id }, process.env.JWT_SECRET_KEY, {
        expiresIn: process.env.JWT_EXPIRY,
    });
};
//User Registeration function
const register = async (req, res) => {
    const { fullName, email, password, mobileNumber, city } = req.body;

    try {
        // Check if the user already exists
        const userExists = await User.findOne({ email });
        if (userExists) {
            return res.status(400).json({message : "User already exists!"}); // 400 is a more appropriate status code for user already existing
        }

        // Create the new user
        const user = await User.create({ email, password, fullName, mobileNumber, city });

        if (user) {
            res.status(201).json({
                id: user._id,
                fullName: user.fullName,
                email: user.email,
                password: user.password,
                mobileNumber: user.mobileNumber,
                token: generateToken(user._id),
            });
            console.log("User created successfully!");
        }

    } catch (e) {
        console.error("Error creating user:", e.message, e.stack); // Log the exact error
        res.status(500).json({message : "User can't be created!"}); // Respond with a generic error message
    }
};

//Login method
const login = async (req, res) => {
    const { email, password } = req.body;

    try {
        const user = await User.findOne({ email });
    //    console.log(user);
        if (!user) return res.status(404).json({ error: 'User not found' });
        if (user && (await user.matchPassword(password))) {
            const Token=generateToken(user._id);
            res.status(200).json({Token,user :{
                id: user._id,
                fullName: user.fullName,
                email: user.email,
            }});
        } else {
            res.status(401).json({ message: 'Invalid email or password' });
        }
    } catch (error) {
        console.error("Error login!", error); 
        res.status(500).json({ message: error.message });
    }
};
export default{
    register,
    login   
}