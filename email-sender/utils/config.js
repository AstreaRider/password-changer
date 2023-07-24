const config = {
  sender: {
    email: process.env.EMAIL_SENDER,
    password: process.env.PASSWORD_EMAIL_SENDER,
  },
  receiver: {
    email: process.env.EMAIL_RECEIVER,
  },
}

module.exports = config