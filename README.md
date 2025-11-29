# 🚀 Advanced Student Management Database Schema

### *Robust PostgreSQL Schema for Educational Systems*

> A professional-grade SQL script designed to power a Student Management System. This schema handles student enrollments, course assignments, teacher allocations, batch scheduling, and registrations with built-in performance optimizations and data integrity checks. Perfect for backend developers building scalable educational apps!

[Overview](#-project-overview) • [Features](#-key-features) • [Installation](#-setup--usage) • [Structure](#-project-structure)

---

##  📸 Project Overview

This repository provides a complete, ready-to-use database schema for managing an educational institution's core operations. Built with PostgreSQL in mind, it emphasizes relational integrity, automation, and query efficiency. Whether you're integrating this into a Python backend (e.g., with FastAPI or Django) or using it standalone, it's designed for real-world scalability.

**Why this schema?**  
- Handles complex relationships like many-to-many (e.g., courses to teachers).  
- Includes advanced PostgreSQL features for production readiness.  
- Easy to extend for full-stack apps, such as adding a REST API layer.

If you're a backend developer like me, this can be a great addition to your portfolio—demonstrating SQL proficiency alongside Python skills!

---

## 🌟 Key Features

This schema is packed with modern database design elements:

### 📊 Core Tables & Relationships

- **Students Table** 👨‍🎓: Stores personal details like name, email, date of birth, enrollment date, and phone number. Includes validations for email format and minimum age (18 years).
- **Courses Table** 📚: Manages course details including name, unique code, description, and credit limits (1-10).
- **Teachers Table** 👩‍🏫: Tracks teacher profiles with name, email, hire date, phone, and department.
- **Batches Table** 🗓️: Schedules batches with names, start/end dates (ensuring end > start), and links to courses via foreign keys.
- **Registrations Table** 📝: Handles student-batch enrollments with payment amounts, registration dates, and status (Pending/Confirmed/Cancelled). Unique constraints prevent duplicates.
- **Course-Teacher Assignments** 🔗: Many-to-many table for assigning teachers to courses with assignment dates.

### 🔧 Advanced Database Elements

- **Indexes** ⚡: Optimized for fast queries on common fields like emails, course codes, and student IDs.
- **Triggers** 🔄: Automated logic, e.g., update registration status to 'Confirmed' if payment > 500.
- **Views** 👀: Pre-defined queries for easy access, like `student_course_view` showing student names, courses, batches, and statuses.
- **Stored Procedures** 🛠️: Reusable functions, e.g., `register_student` to insert a new student and their registration in one transaction with error handling.
- **Constraints** 🛡️: Enforce data integrity with CHECKs (e.g., positive payments, valid dates), UNIQUEs, and CASCADE deletes for cleanups.

### 🔒 Security & Best Practices

- **Data Validation**: Regex for emails, age checks, and status enums.
- **Performance Optimizations**: Indexes on high-query columns to support large-scale data.
- **Error Handling**: Procedures include try-catch (EXCEPTION) for reliable operations.

---

## 🛠️ Tech Stack

- **Database**: PostgreSQL (Compatible with versions 12+)
- **Language**: Pure SQL with PL/pgSQL for procedures and functions
- **No Dependencies**: Runs directly in any PostgreSQL environment—no external libraries needed!
- **Tools Recommended**: pgAdmin, DBeaver, or psql for execution and testing.

---

## 🚀 Setup & Usage

Follow these steps to set up and test the schema on your machine:

### 1. Prerequisites

- Install PostgreSQL: Download from [official site](https://www.postgresql.org/download/) or use a cloud service like Supabase or AWS RDS.
- Optional: Install pgAdmin or any SQL client for visualization and querying.

### 2. Clone the Repository

```
git clone https://github.com/mdwasikhan54/Student-DB-Schema.git
cd Student-DB-Schema
```

### 3. Execute the Script

- Open your PostgreSQL client (e.g., psql).
- Create a new database if needed: `CREATE DATABASE student_management;`
- Connect to it and run the script:
  ```
  psql -U your_username -d student_management -f advanced_schema.sql
  ```
- This will drop any existing tables (for a clean setup) and create all elements.

### 4. Test It Out

- **Insert Sample Data**:
  ```
  -- Add a course
  INSERT INTO course (course_name, course_code, description, credits) 
  VALUES ('Introduction to Python', 'PY101', 'Basics of programming', 3);
  
  -- Add a batch
  INSERT INTO batch (batch_name, start_date, end_date, course_id) 
  VALUES ('Fall 2025', '2025-09-01', '2025-12-31', 1);
  ```

- **Call a Procedure**:
  ```
  CALL register_student('John', 'Doe', 'john@example.com', '2000-01-01', 1, 600);
  ```

- **Query a View**:
  ```
  SELECT * FROM student_course_view;
  ```

**Pro Tip**: For production, connect this schema to your backend app using libraries like SQLAlchemy (Python) or TypeORM (Node.js). Test with dummy data to avoid real-world issues!

---

## 📂 Project Structure

A clean, minimal setup focused on the essentials:

```
Student-DB-Schema/
├── advanced_schema.sql   # 📜 Main SQL script with all definitions (tables, indexes, triggers, views, procedures)
└── README.md             # 📖 This documentation file
```

(Expand as needed—e.g., add sample data scripts or ER diagrams in future updates!)

---

## 📸 Highlights (Code Snippets)

Here are some standout snippets to showcase the schema's sophistication:

**Email Validation Constraint (Regex)**:

```sql
-- In student table
email VARCHAR(255) UNIQUE NOT NULL CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
```

**Trigger for Auto-Status Update**:

```sql
CREATE OR REPLACE FUNCTION update_registration_status()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.payment > 500 THEN
        NEW.status := 'Confirmed';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_update_status
BEFORE INSERT OR UPDATE ON registration
FOR EACH ROW EXECUTE FUNCTION update_registration_status();
```

**Stored Procedure for Registration**:

```sql
CREATE OR REPLACE PROCEDURE register_student(
    p_first_name VARCHAR, p_last_name VARCHAR, p_email VARCHAR, p_dob DATE,
    p_batch_id INT, p_payment INT
)
LANGUAGE plpgsql AS $$
DECLARE
    new_student_id INT;
BEGIN
    -- Insert student
    INSERT INTO student (first_name, last_name, email, date_of_birth)
    VALUES (p_first_name, p_last_name, p_email, p_dob)
    RETURNING student_id INTO new_student_id;
    
    -- Insert registration
    INSERT INTO registration (student_id, batch_id, payment)
    VALUES (new_student_id, p_batch_id, p_payment);
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE NOTICE 'Error registering student: %', SQLERRM;
END;
$$;
```

These examples highlight clean, efficient SQL design with a focus on automation and reliability.

---


### 👨‍💻 Developed by [MD Wasi Khan](https://mdwasikhan-portfolio.netlify.app/)

Aspiring Python Backend Developer | FastAPI Enthusiast | Open Source Contributor  

[GitHub Profile](https://github.com/mdwasikhan54) | [LinkedIn](https://linkedin.com/in/mdwasikhan54)

If you find this project helpful, please drop a ⭐ star on the repo! Contributions and feedback are welcome. 🚀
