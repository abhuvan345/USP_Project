# Student Enrollment System

## Description

The **Student Enrollment System** is a comprehensive solution designed to help enroll students in various courses, generate student IDs, and send them confirmation emails along with their generated ID cards. The system allows administrators to perform these tasks through a GUI interface powered by `zenity` and backend scripts powered by Python. The system also manages student data and stores it in text and CSV files for easy access.

### Key Features:
- Enroll students with personal and course details.
- Validate and collect information such as name, email, phone, course, and enrollment year.
- Generate student ID cards with a unique QR code.
- Send enrollment confirmation emails with registration details.
- Generate and send ID cards in PDF format with QR codes.

## Technologies Used
- **Bash**: For shell scripting and user interface through `zenity`.
- **Python**: For generating and sending ID cards and confirmation emails.
- **Zenity**: For GUI-based input prompts and displaying data.
- **QR Code**: For generating QR codes embedded in student ID cards.
- **ReportLab**: For generating PDF files (ID cards).
- **SMTP**: For sending emails through Gmail’s SMTP server.
- **Gmail**: Used for sending emails.


## Setup Instructions

### Prerequisites

- **Linux (Ubuntu preferred)** or any OS with `bash` and `zenity` installed.
- **Python 3.x**: Required to run Python scripts for email sending and ID card generation.
- **Zenity**: Required for the GUI interface.

#### Step 1: Install Dependencies

- Install `zenity`:
  ```bash
  sudo apt install zenity qrcode reportlab

- executable permission:
   ```bash
   chmod +x enroll_and_id_card.sh

- to run project:
   ```bash
  ./enroll_and_id_card.sh

