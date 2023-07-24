var nodemailer = require('nodemailer');
require('dotenv').config();
const config = require('./utils/config');

var transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: config.sender.email,
    pass: config.sender.password
  },
  tls: {
    rejectUnauthorized: true,
  },
  secureConnection: false,
  debug: true
});

var mailOptions = {
  from: config.sender.email,
  to: config.receiver.email,
  subject: 'Sending Email using Node.js',
  text: 'That was easy! slebewww'
};

transporter.sendMail(mailOptions, function(error, info){
  if (error) {
    console.log(error);
  } else {
    console.log('Email sent: ' + info.response);
  }
});