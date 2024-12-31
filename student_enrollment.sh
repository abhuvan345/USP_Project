#!/bin/bash

# Function to validate email format and repeatedly ask for input if invalid
validate_email() {
    local email=""
    while true; do
        email=$(zenity --entry --title="Student Enrollment" --text="Enter Student Email:")
        if [[ -z "$email" ]]; then
            zenity --error --text="Email cannot be empty."
        elif [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
            zenity --error --text="Invalid email address. Please enter a valid email format."
        else
            echo "$email"
            return 0
        fi
    done
}

# Function to get student phone number and validate it
get_phone_number() {
    local phone=""
    while true; do
        phone=$(zenity --entry --title="Student Enrollment" --text="Enter Student Phone Number (10 digits):")
        if [[ -z "$phone" ]]; then
            zenity --error --text="Phone number cannot be empty."
        elif [[ ! "$phone" =~ ^[0-9]{10}$ ]]; then
            zenity --error --text="Invalid phone number. It must contain exactly 10 digits."
        else
            echo "$phone"
            return 0
        fi
    done
}

# Function to get the year of enrollment using radio buttons
get_student_year() {
    local year=""
    year=$(zenity --list --radiolist \
        --title="Select Enrollment Year" \
        --text="Choose the year the student is enrolling in:" \
        --column="Select" --column="Year" \
        TRUE "1" FALSE "2" FALSE "3")

    if [[ -z "$year" ]]; then
        zenity --error --text="You must select a year."
        exit 1
    fi

    echo "$year"
    return 0
}

# Function to get the course from the predefined list
get_student_course() {
    local course=""
    course=$(zenity --list \
        --title="Select Course" \
        --text="Choose the course the student is enrolling in:" \
        --column="Courses" \
        "CSE (Computer Science & Engineering)" \
        "ISE (Information Science & Engineering)" \
        "AI & DS (Artificial Intelligence & Data Science)" \
        "CS & IoT (Computer Science & Internet of Things)" \
        "AI & ML (Artificial Intelligence & Machine Learning)" \
        "ECE (Electronics & Communication Engineering)" \
        "EEE (Electrical & Electronics Engineering)" \
        "ET (Electronics & Telecommunication Engineering)" \
        "ME (Mechanical Engineering)" \
        "AT (Automotive Technology)")

    if [[ -z "$course" ]]; then
        zenity --error --text="You must select a course."
        exit 1
    fi

    echo "$course"
    return 0
}

# Escape special characters like '&' in input text
escape_string() {
    echo "$1" | sed 's/&/\&amp;/g'
}

# Check for zenity dependency
if ! command -v zenity &> /dev/null; then
    echo "Zenity is not installed. Please install it and try again."
    exit 1
fi

# Prompt for student details
STUDENT_NAME=$(zenity --entry --title="Student Enrollment" --text="Enter Student Name:")
if [[ -z "$STUDENT_NAME" ]]; then
    zenity --error --text="Student Name cannot be empty."
    exit 1
fi

STUDENT_EMAIL=$(validate_email)
STUDENT_PHONE=$(get_phone_number)

STUDENT_COURSE=$(get_student_course)
ENROLLMENT_YEAR=$(get_student_year)

# Escape special characters in strings before displaying them
STUDENT_NAME_ESC=$(escape_string "$STUDENT_NAME")
STUDENT_COURSE_ESC=$(escape_string "$STUDENT_COURSE")

# Confirm enrollment
zenity --question --text="Do you want to enroll $STUDENT_NAME_ESC in the course $STUDENT_COURSE_ESC for year $ENROLLMENT_YEAR?" || exit 0

# Store student details in the file
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

# Send confirmation email
python3 send_email.py "$STUDENT_NAME" "$STUDENT_COURSE" "$ENROLLMENT_YEAR" "$STUDENT_EMAIL"
if [[ $? -ne 0 ]]; then
    zenity --error --text="Failed to send confirmation email to $STUDENT_EMAIL."
else
    zenity --info --text="Confirmation email sent to $STUDENT_EMAIL."
fi

# Display all courses and students enrolled
display_courses() {
    zenity --text-info --filename=students.txt --title="Enrolled Students"
}

display_courses

# Final success message
zenity --info --text="Student '$STUDENT_NAME_ESC' has been successfully enrolled in the course '$STUDENT_COURSE_ESC' for year $ENROLLMENT_YEAR."
