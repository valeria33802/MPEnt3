// nodemailerConfig.js
const nodemailer = require('nodemailer');

// const transporter = nodemailer.createTransport({
//   service: 'Gmail', //
//   auth: {
//     user: 'modp.noreply01@gmail.com',
//     pass: 'modpnoreply0101'
//   }
// });

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "modp.noreply01@gmail.com",
    pass: "wjnc efoe cwnb kugt" // Contraseña generada para la app
  },
});

// // module.exports = transporter;
// const transporter = nodemailer.createTransport({
//   host: 'smtp.mail.yahoo.com',
//   port: 465,           
//   secure: true,       
//   auth: {
//     user: 'modp.noreply01@yahoo.com',       
//     pass: 'modpnoreply0101'  
//   }
// });

module.exports = transporter;