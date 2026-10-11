/*
====================================================================
Assignment : Homework 5 - University Queries
Course     : INS3064 - Multimedia Design and Web Development
Student    : Hoang Thi Yen Nhi
Student ID : 23070466
Date       : October 11, 2026
====================================================================
*/

USE university_db;

/*
Query 1: List All Students
Description: Retrieve all columns and rows from the students table to get a complete list of enrolled students.
Expected Output: All student records with ID, codes, full names, emails, gender, birth date, GPA, and department ID.
*/
SELECT * 
FROM students;

/*
+----+--------------+------------------+-----------------------+--------+---------------+------+---------------+
| id | student_code | full_name        | email                 | gender | date_of_birth | gpa  | department_id |
+----+--------------+------------------+-----------------------+--------+---------------+------+---------------+
|  1 | 23001234     | Nguyễn Thị Hoa   | hoa.nt@st.vnu.edu.vn  | Nữ     | 2005-03-12    | 3.65 |             1 |
|  2 | 23001235     | Trần Minh Tuấn   | tuan.tm@st.vnu.edu.vn | Nam    | 2005-07-20    | 3.40 |             1 |
|  3 | 23001236     | Lê Thảo Linh     | linh.lt@st.vnu.edu.vn | Nữ     | 2005-11-05    | 3.82 |             2 |
|  4 | 23001237     | Phạm Quốc Bảo    | bao.pq@st.vnu.edu.vn  | Nam    | 2005-01-15    | 3.20 |             3 |
|  5 | 23001238     | Hoàng Gia Hân    | han.hg@st.vnu.edu.vn  | Nữ     | 2005-09-28    | 3.90 |             4 |
+----+--------------+------------------+-----------------------+--------+---------------+------+---------------+
(5 rows)
*/


/*
Query 2: High Performing Students
Description: Filters students who have achieved a GPA strictly greater than 3.40.
Expected Output: A list of high-achieving students with their student code, full name, and GPA.
*/
SELECT student_code, full_name, gpa
FROM students
WHERE gpa > 3.40;

/*
+--------------+------------------+------+
| student_code | full_name        | gpa  |
+--------------+------------------+------+
| 23001234     | Nguyễn Thị Hoa   | 3.65 |
| 23001236     | Lê Thảo Linh     | 3.82 |
| 23001238     | Hoàng Gia Hân    | 3.90 |
+--------------+------------------+------+
(3 rows)
*/


/*
Query 3: Specific Department Standard Courses
Description: Selects courses belonging to department ID 1 ('MIS') that award 3 or more credits.
Expected Output: Course codes, titles, and credits matching both criteria.
*/
SELECT course_code, title, credits, department_id
FROM courses
WHERE department_id = 1 AND credits >= 3;

/*
+-------------+-------------------------------------+---------+---------------+
| course_code | title                               | credits | department_id |
+-------------+-------------------------------------+---------+---------------+
| MIS101      | Phân tích và Thiết kế Hệ thống Thô... |       3 |             1 |
+-------------+-------------------------------------+---------+---------------+
(1 rows)
*/


/*
Query 4: Sorted Student Directory
Description: Sorts all students alphabetically by their full name in ascending order.
Expected Output: Student list sorted from A to Z by full name.
*/
SELECT student_code, full_name, email, gpa
FROM students
ORDER BY full_name ASC;

/*
+--------------+------------------+-----------------------+------+
| student_code | full_name        | email                 | gpa  |
+--------------+------------------+-----------------------+------+
| 23001238     | Hoàng Gia Hân    | han.hg@st.vnu.edu.vn  | 3.90 |
| 23001236     | Lê Thảo Linh     | linh.lt@st.vnu.edu.vn | 3.82 |
| 23001234     | Nguyễn Thị Hoa   | hoa.nt@st.vnu.edu.vn  | 3.65 |
| 23001237     | Phạm Quốc Bảo    | bao.pq@st.vnu.edu.vn  | 3.20 |
| 23001235     | Trần Minh Tuấn   | tuan.tm@st.vnu.edu.vn | 3.40 |
+--------------+------------------+-----------------------+------+
(5 rows)
*/


/*
Query 5: Top 3 High Grades
Description: Retrieves the top 3 highest grade scores from the enrollments table using ORDER BY and LIMIT.
Expected Output: The top 3 enrollment records sorted by grade descending.
*/
SELECT 
    id AS enrollment_id, 
    student_id, 
    course_id, 
    grade AS final_grade
FROM enrollments
ORDER BY grade DESC
LIMIT 3;

/*
+---------------+------------+-----------+-------------+
| enrollment_id | student_id | course_id | final_grade |
+---------------+------------+-----------+-------------+
|             9 |          5 |         4 |        9.50 |
|             5 |          3 |         2 |        9.20 |
|             2 |          1 |         2 |        9.00 |
+---------------+------------+-----------+-------------+
(3 rows)
*/


/*
Query 6: Search Instructors by Last Name Pattern
Description: Uses the LIKE operator to search for instructors whose names begin with 'Ng' (e.g., Nguyễn Văn Minh).
Expected Output: List of instructors matching the name pattern.
*/
SELECT id, full_name, email, department_id
FROM instructors
WHERE full_name LIKE 'Ng%';

/*
+----+-------------------+-----------------------+---------------+
| id | full_name         | email                 | department_id |
+----+-------------------+-----------------------+---------------+
|  1 | Nguyễn Văn Minh   | minh.nv@vnu.edu.vn    |             1 |
+----+-------------------+-----------------------+---------------+
(1 rows)
*/


/*
Query 7: Total Students and Average GPA per Department
Description: Uses aggregate functions COUNT, SUM, and AVG with meaningful column aliases to summarize student statistics.
Expected Output: Aggregated student count and average GPA grouped by department ID.
*/
SELECT 
    department_id                  AS dept_id,
    COUNT(id)                      AS total_students,
    ROUND(AVG(gpa), 2)             AS average_gpa
FROM students
GROUP BY department_id;

/*
+---------+----------------+-------------+
| dept_id | total_students | average_gpa |
+---------+----------------+-------------+
|       1 |              2 |        3.53 |
|       2 |              1 |        3.82 |
|       3 |              1 |        3.20 |
|       4 |              1 |        3.90 |
+---------+----------------+-------------+
(4 rows)
*/


/*
Query 8: Departments with Multiple Courses
Description: Groups courses by department_id and uses HAVING to filter departments offering more than 0 courses (or adjust threshold).
Expected Output: Department IDs having courses.
*/
SELECT 
    department_id                  AS dept_id,
    COUNT(id)                      AS course_count
FROM courses
GROUP BY department_id
HAVING COUNT(id) >= 1;

/*
+---------+--------------+
| dept_id | course_count |
+---------+--------------+
|       1 |            1 |
|       2 |            1 |
|       3 |            1 |
|       4 |            1 |
|       5 |            1 |
+---------+--------------+
(5 rows)
*/


/*
Query 9: Courses with Instructor Names
Description: Inner join between courses and instructors tables to map each course title to its assigned instructor.
Expected Output: List of course codes and titles alongside instructor full names.
*/
SELECT 
    c.course_code                  AS code,
    c.title                        AS course_title,
    i.full_name                    AS instructor_name
FROM courses c
JOIN instructors i ON c.instructor_id = i.id
ORDER BY c.course_code;

/*
+--------+-------------------------------------+-----------------+
| code   | course_title                        | instructor_name |
+--------+-------------------------------------+-----------------+
| AF101  | Nguyên lý Kế toán                   | Phạm Thị Thu Hà |
| BA101  | Quản trị Học đại cương              | Lê Hoàng Nam    |
| CS101  | Nhập môn Lập trình Python           | Trần Thị Mai    |
| LC101  | Tiếng Anh Giao tiếp Học thuật       | Đỗ Minh Quân    |
| MIS101 | Phân tích và Thiết kế Hệ thống Thô...| Nguyễn Văn Minh |
+--------+-------------------------------------+-----------------+
(5 rows)
*/


/*
Query 10: Complete Enrollment Details
Description: Joins students, enrollments, courses, and semesters tables to produce a comprehensive grade report.
Expected Output: Detailed list showing student name, course title, semester name, and final grade.
*/
SELECT 
    s.full_name                    AS student_name,
    c.title                        AS course_title,
    sem.name                       AS semester_name,
    e.grade                        AS final_grade
FROM enrollments e
JOIN students s ON e.student_id = s.id
JOIN courses c ON e.course_id = c.id
JOIN semesters sem ON e.semester_id = sem.id
ORDER BY s.full_name, c.title;

/*
+------------------+-------------------------------------+---------------+-------------+
| student_name     | course_title                        | semester_name | final_grade |
+------------------+-------------------------------------+---------------+-------------+
| Hoàng Gia Hân    | Nguyên lý Kế toán                   | Fall 2025     |        9.50 |
| Lê Thảo Linh     | Nhập môn Lập trình Python           | Fall 2025     |        9.20 |
| Lê Thảo Linh     | Tiếng Anh Giao tiếp Học thuật       | Fall 2025     |        8.80 |
| Nguyễn Thị Hoa   | Nhập môn Lập trình Python           | Fall 2025     |        9.00 |
| Nguyễn Thị Hoa   | Phân tích và Thiết kế Hệ thống Thô...| Fall 2025     |        8.50 |
+------------------+-------------------------------------+---------------+-------------+
(5 rows)
*/