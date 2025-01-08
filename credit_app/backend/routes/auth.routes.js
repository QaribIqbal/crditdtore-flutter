import express from 'express';
//const { register, login } = require('../controllers/authController.js');
const router = express.Router();
import controller from '../controllers/auth.controller.js';
const {login , register}=controller;
router.post('/register', register);
router.post('/login', login);

//module.exports = router;
export default router;