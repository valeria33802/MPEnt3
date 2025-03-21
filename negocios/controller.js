// negocios/controller.js
const express = require('express');
const router = express.Router();

const loginRouter = require('./routes/login');
// const usersRouter = require('./routes/users');
// Otros routers...

router.use('/login', loginRouter);
// router.use('/users', usersRouter);

module.exports = router;
