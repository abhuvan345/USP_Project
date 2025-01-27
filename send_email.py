import smtplib
from email.mime.text import MIMEText
import sys

def send_email(student_name, course, year, recipient_email):
    sender_email = "bmsel.2024@gmail.com"
    sender_password = "your-email-password-here"  # Get password from environment variable or securely
    smtp_server = "smtp.gmail.com"
    smtp_port = 587

    subject = "Enrollment Confirmation"
    body = f"""
    Dear {student_name},

    Congratulations! Your registration is confirmed.
    Details:
      - Course: {course}
      - Year: {year}

    Thank you for choosing our institution!

    Best regards,
    BMS College of Engineering
    """
    message = MIMEText(body)
    message["Subject"] = subject
    message["From"] = sender_email
    message["To"] = recipient_email

    try:
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls()
            server.login(sender_email, sender_password)
            server.sendmail(sender_email, recipient_email, message.as_string())
            print(f"Email sent successfully to {recipient_email}.")
    except Exception as e:
        print(f"Failed to send email: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python3 send_email.py <student_name> <course> <year> <recipient_email>")
        sys.exit(1)

    student_name = sys.argv[1]
    course = sys.argv[2]
    year = sys.argv[3]
    recipient_email = sys.argv[4]

    send_email(student_name, course, year, recipient_email)
