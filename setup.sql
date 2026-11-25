-- =============================================================================
-- INS3064 - Homework 10 : Contact Manager (Database Setup)
-- Student Name : Hoang Thi Yen Nhi
-- Student ID   : 23070466
-- Date         : 2026-11-26
-- =============================================================================

CREATE DATABASE IF NOT EXISTS contact_manager
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE contact_manager;

DROP TABLE IF EXISTS contacts;

CREATE TABLE contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE,
    phone VARCHAR(20),
    group_name VARCHAR(50) DEFAULT 'General',
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO contacts (name, email, phone, group_name, notes) VALUES
('Nguyen Minh Anh', 'minhanh.nguyen@example.com', '0912345678', 'Work', 'Project Manager at VNU-IS partner team'),
('Tran Quoc Bao', 'quocbao.tran@example.com', '0987654321', 'Friends', 'University classmate from MIS2023B'),
('Le Thu Ha', 'thuha.le@example.com', '0905112233', 'Family', 'Cousin living in Hanoi'),
('Pham Hoang Nam', 'hoangnam.pham@example.com', '0934556677', 'Work', 'Backend developer contact for API integration'),
('Do Thanh Thao', 'thanhthao.do@example.com', '0978889900', 'General', 'Met at the e-commerce operations workshop'),
('Vu Duc Huy', 'duchuy.vu@example.com', '0945123789', 'Other', 'Graphic designer for freelance packaging');