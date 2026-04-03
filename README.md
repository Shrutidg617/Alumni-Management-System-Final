# ReUnify - Alumni Management System

A Flask + MySQL based alumni management system with:

* Admin login and registration
* Alumni login
* Manage alumni records
* Manage events
* Manage announcements
* Analytics dashboard
* Alumni profile, events, mentorship, and announcements

## Tech Stack

* Python
* Flask
* MySQL
* HTML, CSS, Bootstrap
* Jinja2 templates

## Project Structure

```text
alumni-website/
│
├── app.py
├── schema.sql
├── assets/
│   └── images/
│       ├── event1.png
│       ├── event2.png
│       ├── event3.jpg
│       ├── img1\_event.jpg
│       ├── img2\_event.jpg
│       ├── img3\_event.jpg
│       └── ...
│
└── templates/
    ├── index.html
    ├── login.html
    ├── register.html
    ├── admin/
    │   ├── base\_admin.html
    │   ├── admin.html
    │   ├── manage-alumni.html
    │   ├── manage-events.html
    │   ├── announcements.html
    │   └── analytics.html
    └── alumni/
        ├── base\_alumni.html
        ├── alumni.html
        ├── profile.html
        ├── events.html
        ├── mentorship.html
        └── announcements.html
```

## Prerequisites

Install these before running the project:

* Python 3.10 or above
* MySQL Server
* pip

## 1\. Clone the Repository

```bash
git clone <your-repo-link>
cd alumni-website
```

## 2\. Create and Activate Virtual Environment

### Windows

```bash
python -m venv venv
venv\\Scripts\\activate
```

### macOS / Linux

```bash
python3 -m venv venv
source venv/bin/activate
```

## 3\. Install Python Dependencies

```bash
pip install flask mysql-connector-python
```

## 4\. Create the MySQL Database

Open MySQL command line or MySQL Workbench.

### Option A: Using MySQL command line

```bash
mysql -u root -p
```

Then run:

```sql
CREATE DATABASE IF NOT EXISTS alumni\_management\_system;
USE alumni\_management\_system;
SOURCE C:/full/path/to/your/project/schema.sql;
```

> Important:
> - Use the full path to `schema.sql`
> - Use `/` instead of `\\` in the path

Example:

```sql
SOURCE C:/Users/YourName/OneDrive/alumni-website/schema.sql;
```

### Option B: Using MySQL Workbench

1. Open MySQL Workbench
2. Connect to your local server
3. Open the `schema.sql` file
4. Run the full script

This will:

* create the database
* create tables
* insert sample admin/alumni/events/announcements data

## 5\. Update Database Credentials in `app.py`

Open `app.py` and update this section:

```python
DB\_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "YOUR\_MYSQL\_PASSWORD",
    "database": "alumni\_management\_system"
}
```

Replace `YOUR\_MYSQL\_PASSWORD` with your actual MySQL password.

## 6\. Run the Flask App

```bash
python app.py
```

You should see something like:

```text
\* Running on http://127.0.0.1:5000
```

Open this in your browser:

```text
http://127.0.0.1:5000
```
## Demo Login Credentials

### Admin
- Email: `admin@reunify.com`
- Password: `admin123`
- Role: `Admin`

### Alumni
- Email: `rahul@gmail.com`
- Password: `rahul123`
- Role: `Alumni`

### Student
- Email: `aman@gmail.com`
- Password: `aman123`
- Role: `Student`


Other demo alumni:

* `priya@gmail.com` / `priya123`
* `arjun@gmail.com` / `arjun123`
* `sneha@gmail.com` / `sneha123`

## Features

### Admin
- Register and login
- Manage alumni
- Manage students
- Manage events
- Manage announcements
- View analytics

### Alumni
- Login
- Update profile
- Add LinkedIn profile
- RSVP to alumni/both events
- View announcements
- Accept or reject student mentorship requests

### Student
- Login
- View student/both events
- RSVP to events
- View announcements
- Browse alumni mentors
- Send mentorship requests
## Notes About Static Files

In this project:

* `templates/` contains HTML files
* `assets/` contains images and static resources

In `app.py`, Flask is configured as:

```python
app = Flask(\_\_name\_\_, template\_folder="templates", static\_folder="assets", static\_url\_path="/assets")
```

So image paths in templates should use:

```html
{{ url\_for('static', filename='images/event1.png') }}
```

and not:

```html
{{ url\_for('static', filename='assets/images/event1.png') }}
```

## Common Errors and Fixes

### 1\. Unknown database `alumni\_management\_system`

Cause:

* The database or schema was not imported yet

Fix:

* Run `schema.sql` using MySQL command line or MySQL Workbench

### 2\. Images not showing

Cause:

* Wrong static path in templates

Fix:
Use:

```html
{{ url\_for('static', filename='images/img1\_event.jpg') }}
```

### 3\. Login not working

Check:

* database imported successfully
* demo data exists
* correct role selected in login dropdown
* correct MySQL password in `app.py`

### 4\. `; expected` in HTML near `url\_for`

Cause:

* quote conflict inside `onclick`

Fix:
Use anchor tags:

```html
<a href="{{ url\_for('login') }}" class="login">Login</a>
```

## Useful MySQL Checks

After importing schema, you can verify everything with:

```sql
SHOW DATABASES;
USE alumni\_management\_system;
SHOW TABLES;
SELECT \* FROM admins;
SELECT \* FROM alumni;
```

## Future Improvements

Possible future enhancements:

* Edit alumni and events
* Password hashing
* Student module
* File upload for alumni data
* Export analytics report
* Better charts for analytics
* Role-based authorization improvements

## License

This project is for academic / learning use.

