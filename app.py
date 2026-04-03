from functools import wraps
from flask import Flask, render_template, request, redirect, url_for, session, flash
import mysql.connector

app = Flask(__name__, template_folder="templates", static_folder="assets", static_url_path="/assets")
app.secret_key = "reunify-secret-key"

DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "@1712Shrutidg6",
    "database": "alumni_management_system"
}


def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)


def execute_query(query, params=None, fetchone=False, commit=False):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(query, params or ())
    result = None
    if commit:
        conn.commit()
        result = cursor.lastrowid
    else:
        result = cursor.fetchone() if fetchone else cursor.fetchall()
    cursor.close()
    conn.close()
    return result


def role_required(role):
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            if "user_id" not in session or session.get("role") != role:
                flash("Please login first.", "danger")
                return redirect(url_for("login"))
            return f(*args, **kwargs)
        return wrapper
    return decorator


@app.route("/")
def home():
    return render_template("index.html")


@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        name = request.form["name"]
        email = request.form["email"]
        password = request.form["password"]
        institute_name = request.form["institute_name"]
        designation = request.form.get("designation", "")

        existing = execute_query("SELECT * FROM admins WHERE email = %s", (email,), fetchone=True)
        if existing:
            flash("Admin with this email already exists.", "danger")
            return redirect(url_for("register"))

        execute_query(
            """
            INSERT INTO admins (name, email, password, institute_name, designation)
            VALUES (%s, %s, %s, %s, %s)
            """,
            (name, email, password, institute_name, designation),
            commit=True
        )
        flash("Registration successful. Please login.", "success")
        return redirect(url_for("login"))

    return render_template("register.html")


@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        email = request.form["email"]
        password = request.form["password"]
        role = request.form["role"]

        if role == "admin":
            user = execute_query(
                "SELECT * FROM admins WHERE email = %s AND password = %s",
                (email, password),
                fetchone=True
            )
            if user:
                session["user_id"] = user["admin_id"]
                session["role"] = "admin"
                session["name"] = user["name"]
                flash("Logged in successfully.", "success")
                return redirect(url_for("admin_dashboard"))
        elif role == "alumni":
            user = execute_query(
                "SELECT * FROM alumni WHERE email = %s AND password = %s",
                (email, password),
                fetchone=True
            )
            if user:
                session["user_id"] = user["alumni_id"]
                session["role"] = "alumni"
                session["name"] = user["name"]
                flash("Logged in successfully.", "success")
                return redirect(url_for("alumni_dashboard"))

        flash("Invalid email, password, or role.", "danger")
        return redirect(url_for("login"))

    return render_template("login.html")


@app.route("/logout")
def logout():
    session.clear()
    flash("Logged out successfully.", "info")
    return redirect(url_for("home"))


# ---------------- ADMIN ----------------

@app.route("/admin")
@role_required("admin")
def admin_dashboard():
    stats = {
        "total_alumni": execute_query("SELECT COUNT(*) AS c FROM alumni", fetchone=True)["c"],
        "active_alumni": execute_query("SELECT COUNT(*) AS c FROM alumni WHERE status = 'Active'", fetchone=True)["c"],
        "total_events": execute_query("SELECT COUNT(*) AS c FROM events", fetchone=True)["c"],
        "total_announcements": execute_query("SELECT COUNT(*) AS c FROM announcements", fetchone=True)["c"]
    }
    return render_template("admin/admin.html", active="dashboard", stats=stats, admin_name=session.get("name"))


@app.route("/admin/manage-alumni", methods=["GET", "POST"])
@role_required("admin")
def manage_alumni():
    if request.method == "POST":
        name = request.form["name"]
        email = request.form["email"]
        password = request.form["password"]
        phone = request.form["phone"]
        graduation_year = request.form["graduation_year"]
        department = request.form["department"]
        company = request.form.get("company", "")
        designation = request.form.get("designation", "")
        bio = request.form.get("bio", "")
        status = request.form["status"]

        execute_query(
            """
            INSERT INTO alumni
            (name, email, password, phone, graduation_year, department, company, designation, bio, status)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """,
            (name, email, password, phone, graduation_year, department, company, designation, bio, status),
            commit=True
        )
        flash("Alumni added successfully.", "success")
        return redirect(url_for("manage_alumni"))

    q = request.args.get("q", "").strip()
    dept = request.args.get("department", "").strip()
    year = request.args.get("graduation_year", "").strip()

    query = "SELECT * FROM alumni WHERE 1=1"
    params = []

    if q:
        query += " AND name LIKE %s"
        params.append(f"%{q}%")
    if dept:
        query += " AND department = %s"
        params.append(dept)
    if year:
        query += " AND graduation_year = %s"
        params.append(year)

    query += " ORDER BY alumni_id DESC"

    alumni_list = execute_query(query, tuple(params))
    departments = execute_query("SELECT DISTINCT department FROM alumni ORDER BY department")
    years = execute_query("SELECT DISTINCT graduation_year FROM alumni ORDER BY graduation_year DESC")

    return render_template(
        "admin/manage-alumni.html",
        active="alumni",
        alumni_list=alumni_list,
        departments=departments,
        years=years,
        admin_name=session.get("name")
    )


@app.route("/admin/manage-alumni/delete/<int:alumni_id>", methods=["POST"])
@role_required("admin")
def delete_alumni(alumni_id):
    execute_query("DELETE FROM alumni WHERE alumni_id = %s", (alumni_id,), commit=True)
    flash("Alumni deleted successfully.", "success")
    return redirect(url_for("manage_alumni"))


@app.route("/admin/manage-events", methods=["GET", "POST"])
@role_required("admin")
def manage_events():
    if request.method == "POST":
        title = request.form["title"]
        description = request.form["description"]
        event_date = request.form["event_date"]
        event_time = request.form["event_time"]
        venue = request.form["venue"]
        event_type = request.form["event_type"]
        status = request.form["status"]

        execute_query(
            """
            INSERT INTO events
            (title, description, event_date, event_time, venue, event_type, status, created_by)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """,
            (title, description, event_date, event_time, venue, event_type, status, session["user_id"]),
            commit=True
        )
        flash("Event created successfully.", "success")
        return redirect(url_for("manage_events"))

    events = execute_query(
        """
        SELECT e.*, a.name AS admin_name
        FROM events e
        JOIN admins a ON e.created_by = a.admin_id
        ORDER BY e.event_date ASC
        """
    )
    return render_template("admin/manage-events.html", active="events", events=events, admin_name=session.get("name"))


@app.route("/admin/manage-events/delete/<int:event_id>", methods=["POST"])
@role_required("admin")
def delete_event(event_id):
    execute_query("DELETE FROM events WHERE event_id = %s", (event_id,), commit=True)
    flash("Event deleted successfully.", "success")
    return redirect(url_for("manage_events"))


@app.route("/admin/announcements", methods=["GET", "POST"])
@role_required("admin")
def admin_announcements():
    if request.method == "POST":
        title = request.form["title"]
        message = request.form["message"]
        audience = request.form["audience"]
        posted_on = request.form["posted_on"]

        execute_query(
            """
            INSERT INTO announcements (title, message, audience, posted_by, posted_on)
            VALUES (%s, %s, %s, %s, %s)
            """,
            (title, message, audience, session["user_id"], posted_on),
            commit=True
        )
        flash("Announcement published successfully.", "success")
        return redirect(url_for("admin_announcements"))

    announcements = execute_query(
        """
        SELECT an.*, ad.name AS admin_name
        FROM announcements an
        JOIN admins ad ON an.posted_by = ad.admin_id
        ORDER BY an.posted_on DESC
        """
    )
    return render_template(
        "admin/announcements.html",
        active="announcements",
        announcements=announcements,
        admin_name=session.get("name")
    )


@app.route("/admin/announcements/delete/<int:announcement_id>", methods=["POST"])
@role_required("admin")
def delete_announcement(announcement_id):
    execute_query("DELETE FROM announcements WHERE announcement_id = %s", (announcement_id,), commit=True)
    flash("Announcement deleted successfully.", "success")
    return redirect(url_for("admin_announcements"))


@app.route("/admin/analytics")
@role_required("admin")
def analytics():
    total_alumni = execute_query("SELECT COUNT(*) AS c FROM alumni", fetchone=True)["c"]
    active_alumni = execute_query("SELECT COUNT(*) AS c FROM alumni WHERE status = 'Active'", fetchone=True)["c"]
    total_events = execute_query("SELECT COUNT(*) AS c FROM events", fetchone=True)["c"]
    total_announcements = execute_query("SELECT COUNT(*) AS c FROM announcements", fetchone=True)["c"]
    event_registrations = execute_query("SELECT COUNT(*) AS c FROM event_registrations", fetchone=True)["c"]
    mentorship_requests = execute_query("SELECT COUNT(*) AS c FROM mentorship_requests", fetchone=True)["c"]

    recent_registrations = execute_query(
        """
        SELECT er.registration_status, er.registered_at, al.name AS alumni_name, e.title AS event_title
        FROM event_registrations er
        JOIN alumni al ON er.alumni_id = al.alumni_id
        JOIN events e ON er.event_id = e.event_id
        ORDER BY er.registered_at DESC
        LIMIT 5
        """
    )

    return render_template(
        "admin/analytics.html",
        active="analytics",
        admin_name=session.get("name"),
        total_alumni=total_alumni,
        active_alumni=active_alumni,
        total_events=total_events,
        total_announcements=total_announcements,
        event_registrations=event_registrations,
        mentorship_requests=mentorship_requests,
        recent_registrations=recent_registrations
    )


# ---------------- ALUMNI ----------------

@app.route("/alumni")
@role_required("alumni")
def alumni_dashboard():
    announcements = execute_query("SELECT * FROM announcements ORDER BY posted_on DESC LIMIT 3")
    upcoming_events = execute_query(
        "SELECT * FROM events WHERE status IN ('Upcoming', 'Open') ORDER BY event_date ASC LIMIT 3"
    )
    return render_template(
        "alumni/alumni.html",
        active="dashboard",
        alumni_name=session.get("name"),
        announcements=announcements,
        upcoming_events=upcoming_events
    )


@app.route("/alumni/profile", methods=["GET", "POST"])
@role_required("alumni")
def alumni_profile():
    if request.method == "POST":
        execute_query(
            """
            UPDATE alumni
            SET name=%s, email=%s, phone=%s, graduation_year=%s,
                department=%s, company=%s, designation=%s, bio=%s
            WHERE alumni_id=%s
            """,
            (
                request.form["name"],
                request.form["email"],
                request.form["phone"],
                request.form["graduation_year"],
                request.form["department"],
                request.form["company"],
                request.form["designation"],
                request.form["bio"],
                session["user_id"]
            ),
            commit=True
        )
        session["name"] = request.form["name"]
        flash("Profile updated successfully.", "success")
        return redirect(url_for("alumni_profile"))

    alumni = execute_query("SELECT * FROM alumni WHERE alumni_id = %s", (session["user_id"],), fetchone=True)
    return render_template("alumni/profile.html", active="profile", alumni=alumni, alumni_name=session.get("name"))


@app.route("/alumni/events")
@role_required("alumni")
def alumni_events():
    events = execute_query(
        """
        SELECT e.*,
               er.registration_status
        FROM events e
        LEFT JOIN event_registrations er
          ON e.event_id = er.event_id AND er.alumni_id = %s
        ORDER BY e.event_date ASC
        """,
        (session["user_id"],)
    )
    return render_template("alumni/events.html", active="events", events=events, alumni_name=session.get("name"))


@app.route("/alumni/events/register/<int:event_id>", methods=["POST"])
@role_required("alumni")
def register_event(event_id):
    status = request.form["status"]
    execute_query(
        """
        INSERT INTO event_registrations (alumni_id, event_id, registration_status)
        VALUES (%s, %s, %s)
        ON DUPLICATE KEY UPDATE registration_status = VALUES(registration_status)
        """,
        (session["user_id"], event_id, status),
        commit=True
    )
    flash("Event response saved successfully.", "success")
    return redirect(url_for("alumni_events"))


@app.route("/alumni/mentorship")
@role_required("alumni")
def alumni_mentorship():
    requests_list = execute_query(
        "SELECT * FROM mentorship_requests WHERE mentor_id = %s ORDER BY requested_at DESC",
        (session["user_id"],)
    )
    return render_template(
        "alumni/mentorship.html",
        active="mentorship",
        requests_list=requests_list,
        alumni_name=session.get("name")
    )


@app.route("/alumni/mentorship/update/<int:request_id>", methods=["POST"])
@role_required("alumni")
def update_mentorship_status(request_id):
    status = request.form["status"]
    execute_query(
        "UPDATE mentorship_requests SET status = %s WHERE request_id = %s AND mentor_id = %s",
        (status, request_id, session["user_id"]),
        commit=True
    )
    flash("Mentorship request updated.", "success")
    return redirect(url_for("alumni_mentorship"))


@app.route("/alumni/announcements")
@role_required("alumni")
def alumni_announcements():
    announcements = execute_query(
        """
        SELECT an.*, ad.name AS admin_name
        FROM announcements an
        JOIN admins ad ON an.posted_by = ad.admin_id
        ORDER BY an.posted_on DESC
        """
    )
    return render_template(
        "alumni/announcements.html",
        active="announcements",
        announcements=announcements,
        alumni_name=session.get("name")
    )


if __name__ == "__main__":
    app.run(debug=True)