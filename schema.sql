CREATE DATABASE IF NOT EXISTS alumni_management_system;
USE alumni_management_system;

DROP TABLE IF EXISTS event_registrations;
DROP TABLE IF EXISTS mentorship_requests;
DROP TABLE IF EXISTS announcements;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS alumni;
DROP TABLE IF EXISTS admins;

CREATE TABLE admins (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    institute_name VARCHAR(150) NOT NULL,
    designation VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE alumni (
    alumni_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    graduation_year INT NOT NULL,
    department VARCHAR(100) NOT NULL,
    company VARCHAR(150),
    designation VARCHAR(100),
    linkedin VARCHAR(255),
    bio TEXT,
    status ENUM('Active', 'Inactive', 'Pending') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    department VARCHAR(100) NOT NULL,
    graduation_year INT NOT NULL,
    linkedin VARCHAR(255),
    status ENUM('Active', 'Inactive') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE events (
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    event_time TIME NOT NULL,
    venue VARCHAR(150) NOT NULL,
    event_type VARCHAR(100),
    audience ENUM('Alumni', 'Students', 'Both') DEFAULT 'Both',
    status ENUM('Upcoming', 'Open', 'Completed', 'Draft') DEFAULT 'Upcoming',
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES admins(admin_id) ON DELETE CASCADE
);

CREATE TABLE announcements (
    announcement_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    audience ENUM('Alumni', 'Students', 'Both') DEFAULT 'Both',
    posted_by INT NOT NULL,
    posted_on DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (posted_by) REFERENCES admins(admin_id) ON DELETE CASCADE
);

CREATE TABLE event_registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT NOT NULL,
    user_role ENUM('Alumni', 'Student') NOT NULL,
    alumni_id INT NULL,
    student_id INT NULL,
    registration_status ENUM('Going', 'Interested', 'Cancelled') DEFAULT 'Going',
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_event_alumni (event_id, alumni_id),
    UNIQUE KEY unique_event_student (event_id, student_id),
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    FOREIGN KEY (alumni_id) REFERENCES alumni(alumni_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

CREATE TABLE mentorship_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    mentor_id INT NOT NULL,
    student_id INT NOT NULL,
    topic VARCHAR(200) NOT NULL,
    message TEXT,
    status ENUM('Pending', 'Accepted', 'Rejected', 'Completed') DEFAULT 'Pending',
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mentor_id) REFERENCES alumni(alumni_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

INSERT INTO admins (name, email, password, institute_name, designation)
VALUES
('Admin User', 'admin@reunify.com', 'admin123', 'ABC Institute of Technology', 'Alumni Coordinator');

INSERT INTO alumni (name, email, password, phone, graduation_year, department, company, designation, linkedin, bio, status)
VALUES
('Rahul Sharma', 'rahul@gmail.com', 'rahul123', '9876543210', 2020, 'Computer Science', 'Infosys', 'Software Engineer', 'https://linkedin.com/in/rahulsharma', 'Interested in mentoring students.', 'Active'),
('Priya Nair', 'priya@gmail.com', 'priya123', '9876501234', 2019, 'Electrical', 'TCS', 'Analyst', 'https://linkedin.com/in/priyanair', 'Happy to support alumni events.', 'Active'),
('Arjun Mehta', 'arjun@gmail.com', 'arjun123', '9876512345', 2021, 'Mechanical', 'L&T', 'Design Engineer', '', 'Open to industry talks and collaborations.', 'Pending'),
('Sneha Patel', 'sneha@gmail.com', 'sneha123', '9876523456', 2018, 'Business Administration', 'Deloitte', 'Consultant', 'https://linkedin.com/in/snehapatel', 'Interested in alumni networking programs.', 'Active');

INSERT INTO students (name, email, password, phone, department, graduation_year, linkedin, status)
VALUES
('Aman Verma', 'aman@gmail.com', 'aman123', '9991112222', 'Computer Science', 2026, 'https://linkedin.com/in/amanverma', 'Active'),
('Neha Kapoor', 'neha@gmail.com', 'neha123', '9991113333', 'Electrical', 2025, '', 'Active'),
('Rohit Jain', 'rohit@gmail.com', 'rohit123', '9991114444', 'Mechanical', 2026, '', 'Active');

INSERT INTO events (title, description, event_date, event_time, venue, event_type, audience, status, created_by)
VALUES
('Annual Alumni Meetup', 'Networking, workshops, and keynote sessions with industry leaders.', '2025-10-12', '10:00:00', 'Main Auditorium', 'Meetup', 'Alumni', 'Upcoming', 1),
('Career Guidance Webinar', 'Alumni share their professional journeys and offer tips to students.', '2025-10-25', '16:00:00', 'Online', 'Webinar', 'Students', 'Open', 1),
('Hackathon Highlights', 'Top projects and innovations by students and alumni teams.', '2025-11-05', '11:30:00', 'Innovation Lab', 'Workshop', 'Both', 'Upcoming', 1);

INSERT INTO announcements (title, message, audience, posted_by, posted_on)
VALUES
('Alumni Meetup Registration Open', 'Registration for the Annual Alumni Meetup is now open.', 'Alumni', 1, '2025-10-10'),
('Career Webinar for Students', 'Students are invited to join the career guidance webinar this weekend.', 'Students', 1, '2025-10-22'),
('Hackathon Highlights Released', 'Students and alumni can now check the hackathon highlights.', 'Both', 1, '2025-11-01');

INSERT INTO event_registrations (event_id, user_role, alumni_id, student_id, registration_status)
VALUES
(1, 'Alumni', 1, NULL, 'Going'),
(1, 'Alumni', 2, NULL, 'Interested'),
(2, 'Student', NULL, 1, 'Going'),
(3, 'Student', NULL, 2, 'Interested');

INSERT INTO mentorship_requests (mentor_id, student_id, topic, message, status)
VALUES
(1, 1, 'Software Development Career Guidance', 'Need help with interview preparation and project building.', 'Pending'),
(1, 2, 'Higher Studies and Research', 'Looking for guidance on masters and research paths.', 'Pending'),
(2, 3, 'Switching to Product Roles', 'Need advice on moving from engineering to product management.', 'Accepted');