#!/bin/bash

# Function to validate email format
validate_email() {
    local email=""
    while true; do
        email=$(zenity --entry --title="Student Enrollment" --text="Enter Student Email:")
        if [[ -z "$email" ]]; then
            zenity --error --text="Email cannot be empty."
        elif [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA0-9]{2,}$ ]]; then
            zenity --error --text="Invalid email format."
        else
            echo "$email"
            return 0
        fi
    done
}

# Function to get student phone number
get_phone_number() {
    local phone=""
    while true; do
        phone=$(zenity --entry --title="Student Enrollment" --text="Enter Student Phone Number (10 digits):")
        if [[ -z "$phone" ]]; then
            zenity --error --text="Phone number cannot be empty."
        elif [[ ! "$phone" =~ ^[0-9]{10}$ ]]; then
            zenity --error --text="Invalid phone number. Must be 10 digits."
        else
            echo "$phone"
            return 0
        fi
    done
}

# Function to get the course
get_student_course() {
    local course=""
    course=$(zenity --list --title="Select Course" --text="Choose the student's course:" \
        --column="Courses" \
        "CSE (Computer Science & Engineering)" \
        "ISE (Information Science & Engineering)" \
        "AI & DS (Artificial Intelligence & Data Science)" \
        "CS & IoT (Computer Science & Internet of Things)" \
        "AI & ML (Artificial Intelligence & Machine Learning)" \
        "ECE (Electronics & Communication Engineering)" \
        "EEE (Electrical & Electronics Engineering)" \
        "ME (Mechanical Engineering)")

    if [[ -z "$course" ]]; then
        zenity --error --text="You must select a course."
        exit 1
    fi

    echo "$course"
    return 0
}

# Function to get enrollment year
get_student_year() {
    local year=""
    year=$(zenity --list --radiolist \
        --title="Select Enrollment Year" \
        --text="Choose the enrollment year:" \
        --column="Select" --column="Year" \
        TRUE "1" FALSE "2" FALSE "3")

    if [[ -z "$year" ]]; then
        zenity --error --text="You must select a year."
        exit 1
    fi
}

# Function to generate and send ID card
generate_and_send_id_card() {
    STUDENT_NAME=$1
    STUDENT_ID=$2
    STUDENT_COURSE=$3
    STUDENT_EMAIL=$4

    # Call Python script to generate the ID card and send it
    python3 generate_and_send_id_card.py "$STUDENT_NAME" "$STUDENT_ID" "$STUDENT_COURSE" "$STUDENT_EMAIL"

    # Append the ID card generation details into the students.txt file
    {
        echo "------------------------------------------"
        echo "Student ID: $STUDENT_ID"
        echo "Name: $STUDENT_NAME"
        echo "Course: $STUDENT_COURSE"
        echo "Email: $STUDENT_EMAIL"
        echo "ID Card Generated on: $(date)"
        echo "------------------------------------------"
    } >> students.txt

    zenity --info --text="ID card generated and sent successfully."
}

# Check for zenity
if ! command -v zenity &> /dev/null; then
    echo "Zenity is not installed. Please install it and try again."
    exit 1
fi

# Ask user action
action=$(zenity --list --radiolist \
    --title="Select Action" \
    --text="Choose an action:" \
    --column="Select" --column="Action" \
    TRUE "Enroll Student" FALSE "Send Due Date Reminder" FALSE "Generate and Send ID Card")

if [[ -z "$action" ]]; then
    zenity --error --text="You must select an action."
    exit 1
fi

# Enroll Student
if [[ "$action" == "Enroll Student" ]]; then
    STUDENT_NAME=$(zenity --entry --title="Student Enrollment" --text="Enter Student Name:")
    if [[ -z "$STUDENT_NAME" ]]; then
        zenity --error --text="Student Name cannot be empty."
        exit 1
    fi

    STUDENT_EMAIL=$(validate_email)
    STUDENT_PHONE=$(get_phone_number)
    STUDENT_COURSE=$(get_student_course)
    ENROLLMENT_YEAR=$(get_student_year)
    STUDENT_ID="BMS$(date +%s)"  # Generate unique student ID

    # Save student details to a temporary text file in the specified format
    {
        echo "------------------------------------------"
        echo "Name: $STUDENT_NAME"
        echo "Email: $STUDENT_EMAIL"
        echo "Phone: $STUDENT_PHONE"
        echo "Course: $STUDENT_COURSE"
        echo "Year: $ENROLLMENT_YEAR"
        echo "Enrolled on: $(date)"
        echo "------------------------------------------"
    } >> students.txt

    # Save student details to the CSV for future reference
    echo "$STUDENT_ID, $STUDENT_NAME, $STUDENT_EMAIL, $STUDENT_PHONE, $STUDENT_COURSE, $ENROLLMENT_YEAR" >> students.csv

    # Send Registration Confirmation Email
    python3 send_email.py "$STUDENT_NAME" "$STUDENT_COURSE" "$ENROLLMENT_YEAR" "$STUDENT_EMAIL"

    zenity --info --text="Student enrolled successfully. Registration confirmation email sent."

    # Display all registered students
    zenity --text-info --filename=students.txt  # Use zenity to display the student details

elif [[ "$action" == "Send Due Date Reminder" ]]; then
    STUDENT_NAME=$(zenity --entry --title="Fee Reminder" --text="Enter Student Name:")
    STUDENT_EMAIL=$(validate_email)
    DUE_DATE=$(zenity --entry --title="Fee Due Date" --text="Enter Fee Due Date (YYYY-MM-DD):")

    python3 send_due_email.py "$STUDENT_NAME" "$STUDENT_EMAIL" "$DUE_DATE"
    zenity --info --text="Due date reminder email sent."

elif [[ "$action" == "Generate and Send ID Card" ]]; then
    STUDENT_NAME=$(zenity --entry --title="Generate ID Card" --text="Enter Student Name:")
    STUDENT_EMAIL=$(validate_email)
    STUDENT_ID=$(zenity --entry --title="Generate ID Card" --text="Enter Student ID:")
    STUDENT_COURSE=$(zenity --entry --title="Generate ID Card" --text="Enter Student Course:")

    # Call the separate function to generate and send the ID card
    generate_and_send_id_card "$STUDENT_NAME" "$STUDENT_ID" "$STUDENT_COURSE" "$STUDENT_EMAIL"
fi
