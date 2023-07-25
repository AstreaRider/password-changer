import smtplib
import ssl
import sys

from email.message import EmailMessage

email_sender = sys.argv[1]
email_password = sys.argv[2]
email_receiver = sys.argv[3]

# Set the subject and body of the email
subject = 'VM password has been changed'
with open('content-email.txt') as f:
    body = f.read()

em = EmailMessage()
em['From'] = email_sender
em['To'] = email_receiver
em['Subject'] = subject
em.set_content(body)

# Add SSL (layer of security)
context = ssl.create_default_context()

# Log in and send the email
with smtplib.SMTP_SSL('smtp.gmail.com', 465, context=context) as smtp:
    smtp.login(email_sender, email_password)
    smtp.sendmail(email_sender, email_receiver, em.as_string())