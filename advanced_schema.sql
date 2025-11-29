-- Database Schema for Student Management System (Advanced Version)
-- Author: MD Wasi Khan
-- This script creates tables, indexes, triggers, views, and stored procedures for a robust database.

-- Drop existing tables if they exist (for clean setup)
DROP TABLE IF EXISTS course_teacher CASCADE;
DROP TABLE IF EXISTS registration CASCADE;
DROP TABLE IF EXISTS batch CASCADE;
DROP TABLE IF EXISTS teacher CASCADE;
DROP TABLE IF EXISTS course CASCADE;
DROP TABLE IF EXISTS student CASCADE;

-- Create `student` table with additional constraints
CREATE TABLE student (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),  -- Email validation
    date_of_birth DATE,  -- Changed to DATE for simplicity, add CHECK for age if needed
    enrollment_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    phone_number VARCHAR(20) UNIQUE,  -- Added phone as optional unique field
    CONSTRAINT check_age CHECK (date_of_birth < CURRENT_DATE - INTERVAL '18 years')  -- Ensure student is at least 18
);

-- Create `course` table
CREATE TABLE course (
    course_id SERIAL PRIMARY KEY,
    course_name VARCHAR(255) NOT NULL,
    course_code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    credits INT NOT NULL CHECK (credits > 0 AND credits <= 10)  -- Limit credits
);

-- Create `teacher` table
CREATE TABLE teacher (
    teacher_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    hire_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    phone_number VARCHAR(20),
    department VARCHAR(100)  -- Added department for more details
);

-- Create `batch` table with foreign key
CREATE TABLE batch (
    batch_id SERIAL PRIMARY KEY,
    batch_name VARCHAR(100) NOT NULL,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL CHECK (end_date > start_date),  -- Ensure end > start
    course_id INT NOT NULL,  -- Made NOT NULL for integrity
    CONSTRAINT fk_batch_course FOREIGN KEY (course_id) 
        REFERENCES course(course_id) ON DELETE CASCADE
);

-- Create `registration` table
CREATE TABLE registration (
    registration_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    batch_id INT NOT NULL,
    payment INT NOT NULL CHECK (payment > 0),
    registration_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Confirmed', 'Cancelled')),  -- Added status
    CONSTRAINT fk_registration_student FOREIGN KEY (student_id) 
        REFERENCES student(student_id) ON DELETE CASCADE,
    CONSTRAINT fk_registration_batch FOREIGN KEY (batch_id) 
        REFERENCES batch(batch_id) ON DELETE CASCADE,
    CONSTRAINT unique_student_batch UNIQUE (student_id, batch_id)
);

-- Create `course_teacher` table
CREATE TABLE course_teacher (
    course_teacher_id SERIAL PRIMARY KEY,
    course_id INT NOT NULL,
    teacher_id INT NOT NULL,
    assignment_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_course_teacher_course FOREIGN KEY (course_id) 
        REFERENCES course(course_id) ON DELETE CASCADE,
    CONSTRAINT fk_course_teacher_teacher FOREIGN KEY (teacher_id) 
        REFERENCES teacher(teacher_id) ON DELETE CASCADE,
    CONSTRAINT unique_course_teacher UNIQUE (course_id, teacher_id)
);

-- Indexes for performance
CREATE INDEX idx_student_email ON student(email);
CREATE INDEX idx_course_code ON course(course_code);
CREATE INDEX idx_teacher_email ON teacher(email);
CREATE INDEX idx_registration_student ON registration(student_id);
CREATE INDEX idx_batch_course ON batch(course_id);

-- Trigger: Auto-update status to 'Confirmed' if payment > 500 (example logic)
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

-- View: Student course details
CREATE VIEW student_course_view AS
SELECT 
    s.student_id, s.first_name || ' ' || s.last_name AS student_name,
    c.course_name, b.batch_name, r.registration_date, r.status
FROM student s
JOIN registration r ON s.student_id = r.student_id
JOIN batch b ON r.batch_id = b.batch_id
JOIN course c ON b.course_id = c.course_id;

-- Stored Procedure: Register a new student to a batch
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