// routes/protected.routes.js
import express from 'express';
import { authMiddleware } from '../middleware/authMiddleware.js';

const router = express.Router();

router.get('/protected', authMiddleware, (req, res) => {
    res.status(200).json({ message: 'Welcome to the protected route', user: req.user });
});

export default router;
