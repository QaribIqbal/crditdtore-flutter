const express = require('express');
const router = express.Router();
const {bank_list, user_list} = require('../controllers/banks.controller');
router.get('/banks', bank_list);
router.get('/users', user_list);
module.exports = router;