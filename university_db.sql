-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 05, 2026 at 08:16 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `university_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `courses`
--

CREATE TABLE `courses` (
  `id` int(11) NOT NULL,
  `course_code` varchar(20) NOT NULL,
  `title` varchar(150) NOT NULL,
  `credits` int(11) NOT NULL CHECK (`credits` > 0),
  `department_id` int(11) NOT NULL,
  `instructor_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `courses`
--

INSERT INTO `courses` (`id`, `course_code`, `title`, `credits`, `department_id`, `instructor_id`) VALUES
(1, 'MIS101', 'Phân tích và Thiết kế Hệ thống Thông tin', 3, 1, 1),
(2, 'CS101', 'Nhập môn Lập trình Python', 4, 2, 2),
(3, 'BA101', 'Quản trị Học đại cương', 3, 3, 3),
(4, 'AF101', 'Nguyên lý Kế toán', 3, 4, 4),
(5, 'LC101', 'Tiếng Anh Giao tiếp Học thuật', 2, 5, 5);

-- --------------------------------------------------------

--
-- Table structure for table `departments`
--

CREATE TABLE `departments` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `code` varchar(10) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `departments`
--

INSERT INTO `departments` (`id`, `name`, `code`, `created_at`) VALUES
(1, 'Hệ thống Thông tin Quản lý', 'MIS', '2026-10-06 01:02:53'),
(2, 'Khoa học Máy tính', 'CS', '2026-10-06 01:02:53'),
(3, 'Quản trị Kinh doanh', 'BA', '2026-10-06 01:02:53'),
(4, 'Kế toán - Tài chính', 'AF', '2026-10-06 01:02:53'),
(5, 'Ngôn ngữ và Văn hóa Quốc tế', 'LC', '2026-10-06 01:02:53');

-- --------------------------------------------------------

--
-- Table structure for table `enrollments`
--

CREATE TABLE `enrollments` (
  `id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `semester_id` int(11) NOT NULL,
  `grade` decimal(4,2) DEFAULT NULL CHECK (`grade` is null or `grade` >= 0.00 and `grade` <= 10.00),
  `enrolled_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `enrollments`
--

INSERT INTO `enrollments` (`id`, `student_id`, `course_id`, `semester_id`, `grade`, `enrolled_at`) VALUES
(1, 1, 1, 4, 8.50, '2026-10-06 01:02:54'),
(2, 1, 2, 4, 9.00, '2026-10-06 01:02:54'),
(3, 2, 1, 4, 7.50, '2026-10-06 01:02:54'),
(4, 2, 3, 4, 8.00, '2026-10-06 01:02:54'),
(5, 3, 2, 4, 9.20, '2026-10-06 01:02:54'),
(6, 3, 5, 4, 8.80, '2026-10-06 01:02:54'),
(7, 4, 3, 4, 6.50, '2026-10-06 01:02:54'),
(8, 4, 4, 4, 7.00, '2026-10-06 01:02:54'),
(9, 5, 4, 4, 9.50, '2026-10-06 01:02:54'),
(10, 5, 1, 4, 8.20, '2026-10-06 01:02:54');

-- --------------------------------------------------------

--
-- Table structure for table `instructors`
--

CREATE TABLE `instructors` (
  `id` int(11) NOT NULL,
  `instructor_code` varchar(20) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `gender` enum('Nam','Nữ','Khác') DEFAULT 'Nam',
  `department_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `instructors`
--

INSERT INTO `instructors` (`id`, `instructor_code`, `full_name`, `email`, `gender`, `department_id`) VALUES
(1, 'INS001', 'Nguyễn Văn Minh', 'minh.nv@vnu.edu.vn', 'Nam', 1),
(2, 'INS002', 'Trần Thị Mai', 'mai.tt@vnu.edu.vn', 'Nữ', 2),
(3, 'INS003', 'Lê Hoàng Nam', 'nam.lh@vnu.edu.vn', 'Nam', 3),
(4, 'INS004', 'Phạm Thị Thu Hà', 'ha.ptt@vnu.edu.vn', 'Nữ', 4),
(5, 'INS005', 'Đỗ Minh Quân', 'quan.dm@vnu.edu.vn', 'Nam', 5);

-- --------------------------------------------------------

--
-- Table structure for table `semesters`
--

CREATE TABLE `semesters` (
  `id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `semesters`
--

INSERT INTO `semesters` (`id`, `name`, `start_date`, `end_date`) VALUES
(1, 'Fall 2024', '2024-09-05', '2025-01-15'),
(2, 'Spring 2025', '2025-02-15', '2025-06-30'),
(3, 'Summer 2025', '2025-07-05', '2025-08-25'),
(4, 'Fall 2025', '2025-09-05', '2026-01-15'),
(5, 'Spring 2026', '2026-02-15', '2026-06-30');

-- --------------------------------------------------------

--
-- Table structure for table `students`
--

CREATE TABLE `students` (
  `id` int(11) NOT NULL,
  `student_code` varchar(20) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `gender` enum('Nam','Nữ','Khác') DEFAULT 'Nam',
  `date_of_birth` date NOT NULL,
  `gpa` decimal(3,2) DEFAULT 0.00 CHECK (`gpa` >= 0.00 and `gpa` <= 4.00),
  `department_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `students`
--

INSERT INTO `students` (`id`, `student_code`, `full_name`, `email`, `gender`, `date_of_birth`, `gpa`, `department_id`) VALUES
(1, '23001234', 'Nguyễn Thị Hoa', 'hoa.nt@st.vnu.edu.vn', 'Nữ', '2005-03-12', 3.65, 1),
(2, '23001235', 'Trần Minh Tuấn', 'tuan.tm@st.vnu.edu.vn', 'Nam', '2005-07-20', 3.40, 1),
(3, '23001236', 'Lê Thảo Linh', 'linh.lt@st.vnu.edu.vn', 'Nữ', '2005-11-05', 3.82, 2),
(4, '23001237', 'Phạm Quốc Bảo', 'bao.pq@st.vnu.edu.vn', 'Nam', '2005-01-15', 3.20, 3),
(5, '23001238', 'Hoàng Gia Hân', 'han.hg@st.vnu.edu.vn', 'Nữ', '2005-09-28', 3.90, 4);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `courses`
--
ALTER TABLE `courses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `course_code` (`course_code`),
  ADD KEY `department_id` (`department_id`),
  ADD KEY `instructor_id` (`instructor_id`);

--
-- Indexes for table `departments`
--
ALTER TABLE `departments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Indexes for table `enrollments`
--
ALTER TABLE `enrollments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_enrollment` (`student_id`,`course_id`,`semester_id`),
  ADD KEY `course_id` (`course_id`),
  ADD KEY `semester_id` (`semester_id`);

--
-- Indexes for table `instructors`
--
ALTER TABLE `instructors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `instructor_code` (`instructor_code`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `department_id` (`department_id`);

--
-- Indexes for table `semesters`
--
ALTER TABLE `semesters`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `students`
--
ALTER TABLE `students`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `student_code` (`student_code`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `department_id` (`department_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `courses`
--
ALTER TABLE `courses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `departments`
--
ALTER TABLE `departments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `enrollments`
--
ALTER TABLE `enrollments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `instructors`
--
ALTER TABLE `instructors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `semesters`
--
ALTER TABLE `semesters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `students`
--
ALTER TABLE `students`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `courses`
--
ALTER TABLE `courses`
  ADD CONSTRAINT `courses_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `courses_ibfk_2` FOREIGN KEY (`instructor_id`) REFERENCES `instructors` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `enrollments`
--
ALTER TABLE `enrollments`
  ADD CONSTRAINT `enrollments_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `enrollments_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `enrollments_ibfk_3` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `instructors`
--
ALTER TABLE `instructors`
  ADD CONSTRAINT `instructors_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `students`
--
ALTER TABLE `students`
  ADD CONSTRAINT `students_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
