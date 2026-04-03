CREATE DATABASE IF NOT EXISTS alumni_management_system;
USE alumni_management_system;

DROP TABLE IF EXISTS event_registrations;
DROP TABLE IF EXISTS mentorship_requests;
DROP TABLE IF EXISTS announcements;
DROP TABLE IF EXISTS events;
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
    bio TEXT,
    status ENUM('Active', 'Inactive', 'Pending') DEFAULT 'Active',
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
    status ENUM('Upcoming', 'Open', 'Completed', 'Draft') DEFAULT 'Upcoming',
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES admins(admin_id) ON DELETE CASCADE
);

CREATE TABLE announcements (
    announcement_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    audience VARCHAR(100) DEFAULT 'All Alumni',
    posted_by INT NOT NULL,
    posted_on DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (posted_by) REFERENCES admins(admin_id) ON DELETE CASCADE
);

CREATE TABLE event_registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    alumni_id INT NOT NULL,
    event_id INT NOT NULL,
    registration_status ENUM('Going', 'Interested', 'Cancelled') DEFAULT 'Going',
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_alumni_event (alumni_id, event_id),
    FOREIGN KEY (alumni_id) REFERENCES alumni(alumni_id) ON DELETE CASCADE,
    FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE
);

CREATE TABLE mentorship_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    mentor_id INT NOT NULL,
    mentee_name VARCHAR(100) NOT NULL,
    mentee_email VARCHAR(100),
    topic VARCHAR(200) NOT NULL,
    message TEXT,
    status ENUM('Pending', 'Accepted', 'Rejected', 'Completed') DEFAULT 'Pending',
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mentor_id) REFERENCES alumni(alumni_id) ON DELETE CASCADE
);

INSERT INTO admins (name, email, password, institute_name, designation)
VALUES
('Admin User', 'admin@reunify.com', 'admin123', 'ABC Institute of Technology', 'Alumni Coordinator');

INSERT INTO alumni (name, email, password, phone, graduation_year, department, company, designation, bio, status)
VALUES
('Rahul Sharma', 'rahul@gmail.com', 'rahul123', '9876543210', 2020, 'Computer Science', 'Infosys', 'Software Engineer', 'Interested in mentoring students.', 'Active'),
('Priya Nair', 'priya@gmail.com', 'priya123', '9876501234', 2019, 'Electrical', 'TCS', 'Analyst', 'Happy to support alumni events.', 'Active'),
('Arjun Mehta', 'arjun@gmail.com', 'arjun123', '9876512345', 2021, 'Mechanical', 'L&T', 'Design Engineer', 'Open to industry talks and collaborations.', 'Pending'),
('Sneha Patel', 'sneha@gmail.com', 'sneha123', '9876523456', 2018, 'Business Administration', 'Deloitte', 'Consultant', 'Interested in alumni networking programs.', 'Active');

INSERT INTO events (title, description, event_date, event_time, venue, event_type, status, created_by)
VALUES
('Annual Alumni Meetup', 'Networking, workshops, and keynote sessions with industry leaders.', '2025-10-12', '10:00:00', 'Main Auditorium', 'Meetup', 'Upcoming', 1),
('Career Guidance Webinar', 'Alumni share their professional journeys and offer tips to students.', '2025-10-25', '16:00:00', 'Online', 'Webinar', 'Open', 1),
('Hackathon Highlights', 'Top projects and innovations by students and alumni teams.', '2025-11-05', '11:30:00', 'Innovation Lab', 'Workshop', 'Draft', 1);

INSERT INTO announcements (title, message, audience, posted_by, posted_on)
VALUES
('Alumni Meetup Registration Open', 'Registration for the Annual Alumni Meetup is now open for all passed out students.', 'All Alumni', 1, '2025-10-10'),
('Webinar on Career Growth', 'Join our special session with distinguished alumni this weekend.', 'All Alumni', 1, '2025-10-22'),
('Database Verification Drive', 'All alumni are requested to verify their contact details before the end of the month.', 'All Alumni', 1, '2025-11-01');

INSERT INTO event_registrations (alumni_id, event_id, registration_status)
VALUES
(1, 1, 'Going'),
(2, 1, 'Interested'),
(1, 2, 'Going'),
(4, 2, 'Going');

INSERT INTO mentorship_requests (mentor_id, mentee_name, mentee_email, topic, message, status)
VALUES
(1, 'Aman Verma', 'aman@gmail.com', 'Software Development Career Guidance', 'Need help with interview preparation and project building.', 'Pending'),
(1, 'Neha Kapoor', 'neha@gmail.com', 'Higher Studies and Research', 'Looking for guidance on masters and research paths.', 'Pending'),
(2, 'Rohit Jain', 'rohit@gmail.com', 'Switching to Product Roles', 'Need advice on moving from engineering to product management.', 'Accepted');