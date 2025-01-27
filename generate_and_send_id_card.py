import qrcode
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.pdfgen import canvas
import smtplib
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email import encoders
import sys

def generate_id_card(student_name, student_id, course):
    # Generate the QR code
    qr_data = f"Name: {student_name}\nEmail: {student_id}@bmsce.ac.in\nStudent ID: {student_id}"
    qr_img = f"{student_id}_qrcode.png"
    qr = qrcode.make(qr_data)
    qr.save(qr_img)

    # Generate ID card PDF
    pdf_filename = f"{student_id}_id_card.pdf"
    c = canvas.Canvas(pdf_filename, pagesize=letter)
    c.setFont("Helvetica", 12)
    c.drawString(100, 750, f"Student Name: {student_name}")
    c.drawString(100, 730, f"Student ID: {student_id}")
    c.drawString(100, 710, f"Course: {course}")
    c.drawString(100, 690, f"QR Code:")
    c.drawImage(qr_img, 100, 600, width=100, height=100)
    c.save()

    return pdf_filename, qr_img

def send_id_card(student_name, student_id, student_email, pdf_filename):
    sender_email = "bmsel.2024@gmail.com"
    sender_password = "your-email-password-here"
    smtp_server = "smtp.gmail.com"
    smtp_port = 587

    subject = "Your Student ID Card"
    body = f"""
    Dear {student_name},

    Please find attached your Student ID card.

    Best regards,
    BMS College of Engineering
    """
    message = MIMEText(body)
    message["Subject"] = subject
    message["From"] = sender_email
    message["To"] = student_email

    part = MIMEBase("application", "octet-stream")
    with open(pdf_filename, "rb") as attachment:
        part.set_payload(attachment.read())
        encoders.encode_base64(part)
        part.add_header(
            "Content-Disposition", f"attachment; filename={pdf_filename}"
        )
        message.attach(part)

    try:
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls()
            server.login(sender_email, sender_password)
            server.sendmail(sender_email, student_email, message.as_string())
            print(f"ID Card sent successfully to {student_email}.")
    except Exception as e:
        print(f"Failed to send email: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python3 generate_and_send_id_card.py <student_name> <student_id> <course> <student_email>")
        sys.exit(1)

    student_name = sys.argv[1]
    student_id = sys.argv[2]
    course = sys.argv[3]
    student_email = sys.argv[4]

    pdf_filename, qr_img = generate_id_card(student_name, student_id, course)
    send_id_card(student_name, student_id, student_email, pdf_filename)
