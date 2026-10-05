-- =====================================================================
-- Name: Hoàng Thị Yến Nhi
-- Student ID: 23070466
-- Assignment: Database Design - University DB
-- Date: 2026-10-06
-- Description: Complete SQL script to create university_db database,
--              tables with comprehensive constraints, and sample data.
-- =====================================================================

-- 1. Tạo và chọn database
DROP DATABASE IF EXISTS university_db;
CREATE DATABASE university_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE university_db;

-- 2. Bảng departments: Lưu thông tin các khoa/phòng ban
DROP TABLE IF EXISTS enrollments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS instructors;
DROP TABLE IF EXISTS semesters;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    id INT AUTO_INCREMENT PRIMARY KEY, -- Khóa chính tự tăng
    name VARCHAR(100) NOT NULL UNIQUE,  -- Tên khoa (bắt buộc, duy nhất)
    code VARCHAR(10) NOT NULL UNIQUE,   -- Mã khoa (bắt buộc, duy nhất)
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP -- Thời điểm tạo bản ghi
) ENGINE=InnoDB;

-- 3. Bảng semesters: Lưu thông tin học kỳ
CREATE TABLE semesters (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,   -- Tên học kỳ (VD: Fall 2024, Spring 2025)
    start_date DATE NOT NULL,           -- Ngày bắt đầu học kỳ
    end_date DATE NOT NULL              -- Ngày kết thúc học kỳ
) ENGINE=InnoDB;

-- 4. Bảng instructors: Lưu thông tin giảng viên (thuộc về một khoa)
CREATE TABLE instructors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    instructor_code VARCHAR(20) NOT NULL UNIQUE, -- Mã giảng viên
    full_name VARCHAR(100) NOT NULL,             -- Họ và tên giảng viên
    email VARCHAR(100) NOT NULL UNIQUE,          -- Email liên hệ
    gender ENUM('Nam', 'Nữ', 'Khác') DEFAULT 'Nam', -- Giới tính
    department_id INT NOT NULL,                  -- Khoa mà giảng viên công tác
    FOREIGN KEY (department_id) REFERENCES departments(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 5. Bảng students: Lưu thông tin sinh viên (thuộc về một khoa - chuyên ngành)
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_code VARCHAR(20) NOT NULL UNIQUE,    -- Mã sinh viên (MSSV)
    full_name VARCHAR(100) NOT NULL,             -- Họ và tên sinh viên
    email VARCHAR(100) NOT NULL UNIQUE,          -- Email sinh viên
    gender ENUM('Nam', 'Nữ', 'Khác') DEFAULT 'Nam', -- Giới tính
    date_of_birth DATE NOT NULL,                 -- Ngày sinh
    gpa DECIMAL(3,2) DEFAULT 0.00 CHECK (gpa >= 0.00 AND gpa <= 4.00), -- Điểm trung bình (0.00 - 4.00)
    department_id INT NOT NULL,                  -- Khoa chuyên ngành của sinh viên
    FOREIGN KEY (department_id) REFERENCES departments(id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 6. Bảng courses: Lưu thông tin học phần/môn học (thuộc 1 khoa, do 1 giảng viên phụ trách)
CREATE TABLE courses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(20) NOT NULL UNIQUE,     -- Mã học phần
    title VARCHAR(150) NOT NULL,                 -- Tên học phần
    credits INT NOT NULL CHECK (credits > 0),    -- Số tín chỉ (phải lớn hơn 0)
    department_id INT NOT NULL,                  -- Khoa quản lý học phần
    instructor_id INT NOT NULL,                  -- Giảng viên giảng dạy chính
    FOREIGN KEY (department_id) REFERENCES departments(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (instructor_id) REFERENCES instructors(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 7. Bảng enrollments: Bảng trung gian (M:N) quản lý việc sinh viên đăng ký môn học theo học kỳ
CREATE TABLE enrollments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,                     -- Sinh viên đăng ký
    course_id INT NOT NULL,                      -- Học phần đăng ký
    semester_id INT NOT NULL,                    -- Học kỳ đăng ký
    grade DECIMAL(4,2) CHECK (grade IS NULL OR (grade >= 0.00 AND grade <= 10.00)), -- Điểm số
    enrolled_at DATETIME DEFAULT CURRENT_TIMESTAMP, -- Thời gian đăng ký
    -- Ràng buộc kết hợp duy nhất để tránh sinh viên đăng ký trùng một môn trong cùng một học kỳ
    UNIQUE KEY `unique_enrollment` (`student_id`, `course_id`, `semester_id`),
    FOREIGN KEY (student_id) REFERENCES students(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (semester_id) REFERENCES semesters(id)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =====================================================================
-- INSERT SAMPLE DATA (Dữ liệu mẫu tiếng Việt, >= 5 bản ghi mỗi bảng chính)
-- =====================================================================

-- 1. Dữ liệu bảng departments (5 bản ghi)
INSERT INTO departments (name, code) VALUES
('Hệ thống Thông tin Quản lý', 'MIS'),
('Khoa học Máy tính', 'CS'),
('Quản trị Kinh doanh', 'BA'),
('Kế toán - Tài chính', 'AF'),
('Ngôn ngữ và Văn hóa Quốc tế', 'LC');

-- 2. Dữ liệu bảng semesters (5 bản ghi)
INSERT INTO semesters (name, start_date, end_date) VALUES
('Fall 2024', '2024-09-05', '2025-01-15'),
('Spring 2025', '2025-02-15', '2025-06-30'),
('Summer 2025', '2025-07-05', '2025-08-25'),
('Fall 2025', '2025-09-05', '2026-01-15'),
('Spring 2026', '2026-02-15', '2026-06-30');

-- 3. Dữ liệu bảng instructors (5 bản ghi)
INSERT INTO instructors (instructor_code, full_name, email, gender, department_id) VALUES
('INS001', 'Nguyễn Văn Minh', 'minh.nv@vnu.edu.vn', 'Nam', 1),
('INS002', 'Trần Thị Mai', 'mai.tt@vnu.edu.vn', 'Nữ', 2),
('INS003', 'Lê Hoàng Nam', 'nam.lh@vnu.edu.vn', 'Nam', 3),
('INS004', 'Phạm Thị Thu Hà', 'ha.ptt@vnu.edu.vn', 'Nữ', 4),
('INS005', 'Đỗ Minh Quân', 'quan.dm@vnu.edu.vn', 'Nam', 5);

-- 4. Dữ liệu bảng students (5 bản ghi)
INSERT INTO students (student_code, full_name, email, gender, date_of_birth, gpa, department_id) VALUES
('23001234', 'Nguyễn Thị Hoa', 'hoa.nt@st.vnu.edu.vn', 'Nữ', '2005-03-12', 3.65, 1),
('23001235', 'Trần Minh Tuấn', 'tuan.tm@st.vnu.edu.vn', 'Nam', '2005-07-20', 3.40, 1),
('23001236', 'Lê Thảo Linh', 'linh.lt@st.vnu.edu.vn', 'Nữ', '2005-11-05', 3.82, 2),
('23001237', 'Phạm Quốc Bảo', 'bao.pq@st.vnu.edu.vn', 'Nam', '2005-01-15', 3.20, 3),
('23001238', 'Hoàng Gia Hân', 'han.hg@st.vnu.edu.vn', 'Nữ', '2005-09-28', 3.90, 4);

-- 5. Dữ liệu bảng courses (5 bản ghi)
INSERT INTO courses (course_code, title, credits, department_id, instructor_id) VALUES
('MIS101', 'Phân tích và Thiết kế Hệ thống Thông tin', 3, 1, 1),
('CS101', 'Nhập môn Lập trình Python', 4, 2, 2),
('BA101', 'Quản trị Học đại cương', 3, 3, 3),
('AF101', 'Nguyên lý Kế toán', 3, 4, 4),
('LC101', 'Tiếng Anh Giao tiếp Học thuật', 2, 5, 5);

-- 6. Dữ liệu bảng enrollments (10 bản ghi)
INSERT INTO enrollments (student_id, course_id, semester_id, grade) VALUES
(1, 1, 4, 8.50),
(1, 2, 4, 9.00),
(2, 1, 4, 7.50),
(2, 3, 4, 8.00),
(3, 2, 4, 9.20),
(3, 5, 4, 8.80),
(4, 3, 4, 6.50),
(4, 4, 4, 7.00),
(5, 4, 4, 9.50),
(5, 1, 4, 8.20);