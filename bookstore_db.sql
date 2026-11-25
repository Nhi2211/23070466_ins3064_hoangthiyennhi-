-- =====================================================================
--  INS3064 - Homework 6 : Online Bookstore Database
--  File      : bookstore_db.sql
--  RDBMS     : MySQL 8.0+ / MariaDB 10.4+   (InnoDB, utf8mb4)
--  Contents  : 1. 3NF explanation
--              2. Database + 10 tables with full constraints
--              3. Sample data (all foreign keys linked)
--              4. Reporting view + sanity checks for the demo
--  How to run: phpMyAdmin > Import, or
--              mysql -u root -p < bookstore_db.sql
--  Note      : the script is re-runnable; it drops and recreates the
--              10 tables of the bookstore schema.
-- =====================================================================


-- =====================================================================
-- 1. NORMALIZATION: HOW THIS DESIGN REACHES 3NF
-- ---------------------------------------------------------------------
-- 1NF - atomic values, no repeating groups
--   * Every column stores one scalar value. A customer address is split
--     into street_address / city / state_province / postal_code /
--     country instead of one multi-part string, and orders keep their own
--     copy of the same parts for shipping.
--   * An order never stores "book1, book2, ..." in one column: each book
--     bought is a separate order_items row.
--   * Book-to-author and book-to-category links are never stored as comma
--     separated lists; each pair is one row in book_authors /
--     book_categories.
--
-- 2NF - no partial dependency on a composite key
--   * Every entity has a single-column surrogate primary key
--     (author_id, book_id, order_id, ...), so a non-key column cannot
--     depend on only part of the key in the main tables.
--   * The only composite keys are the junction tables
--     book_authors (book_id, author_id) and
--     book_categories (book_id, category_id). The only non-key attribute,
--     book_authors.author_order, describes the pairing itself (the
--     position of that author on that book), so it depends on the whole
--     key, never on book_id or author_id alone.
--
-- 3NF - no transitive dependency (non-key -> non-key)
--   * books stores publisher_id only. Publisher name, address and
--     website exist once in publishers, so book_id -> publisher_id ->
--     publisher details is broken by the lookup table.
--   * categories stores parent_category_id instead of repeating the
--     parent name, so renaming a parent happens in exactly one row.
--   * order_items stores book_id and a unit_price snapshot; it does not
--     duplicate title, ISBN or publisher name of the book.
--   * reviews stores customer_id and book_id; reviewer name and book
--     title are reached through foreign keys, never copied.
--   * orders stores customer_id plus a shipping snapshot. No table stores
--     city -> postal_code or postal_code -> city dependencies; those
--     columns simply describe one customer or one delivery.
--   * order_items.subtotal is a STORED GENERATED column computed by the
--     engine as quantity * unit_price, so it can never disagree with its
--     source columns.
--
-- Documented deliberate exceptions (these are NOT 3NF violations):
--   * orders.shipping_* is a historical snapshot of where a parcel was
--     sent. It must NOT follow later edits of the customer address, so it
--     is intentionally not replaced by a foreign key to a current
--     address.
--   * order_items.unit_price is the price charged at purchase time, not
--     the current books.price. Both are time-dependent facts rather than
--     duplicated current data.
--   * orders.total_amount is a cached aggregate of the child rows
--     (order_items.subtotal + shipping_fee). It is not functionally
--     dependent on another non-key column of orders; the view
--     v_order_summary recomputes it so it can be audited.
-- =====================================================================


SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS bookstore_db
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE bookstore_db;

-- Drop children before parents so the script can be re-run safely.
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS book_categories;
DROP TABLE IF EXISTS book_authors;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS publishers;
DROP TABLE IF EXISTS authors;


-- =====================================================================
-- 2. SCHEMA
-- =====================================================================

-- ---------------------------------------------------------------------
-- authors : people who write books (M:N with books via book_authors)
-- ---------------------------------------------------------------------
CREATE TABLE authors (
  author_id    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  full_name    VARCHAR(150)  NOT NULL,
  nationality  VARCHAR(60)   DEFAULT NULL,
  birth_date   DATE          DEFAULT NULL,
  bio          TEXT          DEFAULT NULL,
  website      VARCHAR(255)  DEFAULT NULL,
  created_at   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (author_id),
  KEY idx_authors_name (full_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ---------------------------------------------------------------------
-- publishers : one publisher publishes many books (1:N)
-- ---------------------------------------------------------------------
CREATE TABLE publishers (
  publisher_id  INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  name          VARCHAR(150)    NOT NULL,
  address       VARCHAR(255)    DEFAULT NULL,
  city          VARCHAR(100)    DEFAULT NULL,
  country       VARCHAR(100)    NOT NULL,
  website       VARCHAR(255)    DEFAULT NULL,
  email         VARCHAR(150)    DEFAULT NULL,
  phone         VARCHAR(30)     DEFAULT NULL,
  founded_year  SMALLINT        DEFAULT NULL,
  created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (publisher_id),
  UNIQUE KEY uq_publishers_name (name),
  UNIQUE KEY uq_publishers_email (email),
  CONSTRAINT chk_publishers_founded_year
    CHECK (founded_year IS NULL OR founded_year BETWEEN 1400 AND 2100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ---------------------------------------------------------------------
-- categories : hierarchical genres (self-referencing 1:N)
--              parent_category_id = NULL for a root category
-- ---------------------------------------------------------------------
CREATE TABLE categories (
  category_id         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  name                VARCHAR(100)  NOT NULL,
  description         TEXT          DEFAULT NULL,
  parent_category_id  INT UNSIGNED  DEFAULT NULL,
  created_at          DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (category_id),
  UNIQUE KEY uq_categories_name (name),
  KEY idx_categories_parent (parent_category_id),
  CONSTRAINT fk_categories_parent
    FOREIGN KEY (parent_category_id) REFERENCES categories (category_id)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ---------------------------------------------------------------------
-- books : catalog; belongs to one publisher (1:N)
-- ---------------------------------------------------------------------
CREATE TABLE books (
  book_id           INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  title             VARCHAR(255)   NOT NULL,
  isbn              VARCHAR(13)    NOT NULL,
  publisher_id      INT UNSIGNED   NOT NULL,
  price             DECIMAL(10,2)  NOT NULL,
  stock             INT            NOT NULL DEFAULT 0,
  publication_date  DATE           NOT NULL,
  language          VARCHAR(30)    NOT NULL DEFAULT 'English',
  pages             INT            DEFAULT NULL,
  format            ENUM('Hardcover','Paperback','Ebook') NOT NULL DEFAULT 'Paperback',
  description       TEXT           DEFAULT NULL,
  cover_image_url   VARCHAR(500)   DEFAULT NULL,
  created_at        DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                   ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (book_id),
  UNIQUE KEY uq_books_isbn (isbn),
  KEY idx_books_title (title(100)),
  KEY idx_books_publisher (publisher_id),
  KEY idx_books_publication_date (publication_date),
  CONSTRAINT fk_books_publisher
    FOREIGN KEY (publisher_id) REFERENCES publishers (publisher_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_books_price          CHECK (price > 0),
  CONSTRAINT chk_books_stock          CHECK (stock >= 0),
  CONSTRAINT chk_books_isbn_length    CHECK (CHAR_LENGTH(isbn) IN (10, 13)),
  CONSTRAINT chk_books_pages          CHECK (pages IS NULL OR pages > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ---------------------------------------------------------------------
-- book_authors : junction table for the M:N relationship
--                PK (book_id, author_id) prevents duplicate pairs
-- ---------------------------------------------------------------------
CREATE TABLE book_authors (
  book_id       INT UNSIGNED      NOT NULL,
  author_id     INT UNSIGNED      NOT NULL,
  author_order  TINYINT UNSIGNED  NOT NULL DEFAULT 1,
  PRIMARY KEY (book_id, author_id),
  UNIQUE KEY uq_book_authors_order (book_id, author_order),
  KEY idx_book_authors_author (author_id),
  CONSTRAINT fk_book_authors_book
    FOREIGN KEY (book_id) REFERENCES books (book_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_book_authors_author
    FOREIGN KEY (author_id) REFERENCES authors (author_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_book_authors_order CHECK (author_order >= 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ---------------------------------------------------------------------
-- book_categories : junction table for the M:N relationship
-- ---------------------------------------------------------------------
CREATE TABLE book_categories (
  book_id      INT UNSIGNED  NOT NULL,
  category_id  INT UNSIGNED  NOT NULL,
  PRIMARY KEY (book_id, category_id),
  KEY idx_book_categories_category (category_id),
  CONSTRAINT fk_book_categories_book
    FOREIGN KEY (book_id) REFERENCES books (book_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_book_categories_category
    FOREIGN KEY (category_id) REFERENCES categories (category_id)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ---------------------------------------------------------------------
-- customers : accounts; one customer places many orders (1:N)
--             passwords are stored only as a hash
-- ---------------------------------------------------------------------
CREATE TABLE customers (
  customer_id     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  first_name      VARCHAR(60)   NOT NULL,
  last_name       VARCHAR(60)   NOT NULL,
  email           VARCHAR(150)  NOT NULL,
  password_hash   VARCHAR(255)  NOT NULL,
  phone           VARCHAR(30)   DEFAULT NULL,
  street_address  VARCHAR(255)  DEFAULT NULL,
  city            VARCHAR(100)  DEFAULT NULL,
  state_province  VARCHAR(100)  DEFAULT NULL,
  postal_code     VARCHAR(20)   DEFAULT NULL,
  country         VARCHAR(100)  NOT NULL,
  is_active       TINYINT(1)    NOT NULL DEFAULT 1,
  created_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
                                ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (customer_id),
  UNIQUE KEY uq_customers_email (email),
  CONSTRAINT chk_customers_email_format CHECK (email LIKE '%@%.%'),
  CONSTRAINT chk_customers_hash_length  CHECK (CHAR_LENGTH(password_hash) >= 20),
  CONSTRAINT chk_customers_is_active    CHECK (is_active IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ---------------------------------------------------------------------
-- orders : order header; belongs to one customer (1:N)
--          shipping_* is a delivery snapshot, not the live address
-- ---------------------------------------------------------------------
CREATE TABLE orders (
  order_id             INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  customer_id          INT UNSIGNED   NOT NULL,
  order_date           DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status               ENUM('pending','processing','shipped','delivered','cancelled')
                                      NOT NULL DEFAULT 'pending',
  payment_method       ENUM('credit_card','paypal','bank_transfer','cash_on_delivery')
                                      NOT NULL DEFAULT 'credit_card',
  shipping_fee         DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
  total_amount         DECIMAL(12,2)  NOT NULL DEFAULT 0.00,
  shipping_address     VARCHAR(255)   NOT NULL,
  shipping_city        VARCHAR(100)   NOT NULL,
  shipping_state       VARCHAR(100)   DEFAULT NULL,
  shipping_postal_code VARCHAR(20)    DEFAULT NULL,
  shipping_country     VARCHAR(100)   NOT NULL,
  notes                VARCHAR(500)   DEFAULT NULL,
  updated_at           DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                      ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (order_id),
  KEY idx_orders_customer (customer_id),
  KEY idx_orders_status (status),
  KEY idx_orders_order_date (order_date),
  CONSTRAINT fk_orders_customer
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_orders_shipping_fee CHECK (shipping_fee >= 0),
  CONSTRAINT chk_orders_total_amount CHECK (total_amount >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ---------------------------------------------------------------------
-- order_items : order lines; M:N between orders and books
--               unit_price is the price charged at purchase time.
--               subtotal is generated so it can never drift.
-- ---------------------------------------------------------------------
CREATE TABLE order_items (
  order_item_id  INT UNSIGNED   NOT NULL AUTO_INCREMENT,
  order_id       INT UNSIGNED   NOT NULL,
  book_id        INT UNSIGNED   NOT NULL,
  quantity       INT            NOT NULL DEFAULT 1,
  unit_price     DECIMAL(10,2)  NOT NULL,
  subtotal       DECIMAL(12,2)  GENERATED ALWAYS AS (quantity * unit_price) STORED,
  PRIMARY KEY (order_item_id),
  UNIQUE KEY uq_order_items_order_book (order_id, book_id),
  KEY idx_order_items_book (book_id),
  CONSTRAINT fk_order_items_order
    FOREIGN KEY (order_id) REFERENCES orders (order_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_order_items_book
    FOREIGN KEY (book_id) REFERENCES books (book_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_order_items_quantity   CHECK (quantity > 0),
  CONSTRAINT chk_order_items_unit_price CHECK (unit_price > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ---------------------------------------------------------------------
-- reviews : one review per customer per book; 1:N from customers and books
-- ---------------------------------------------------------------------
CREATE TABLE reviews (
  review_id    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  book_id      INT UNSIGNED  NOT NULL,
  customer_id  INT UNSIGNED  NOT NULL,
  rating       TINYINT       NOT NULL,
  `comment`    TEXT          DEFAULT NULL,
  review_date  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (review_id),
  UNIQUE KEY uq_reviews_book_customer (book_id, customer_id),
  KEY idx_reviews_customer (customer_id),
  KEY idx_reviews_rating (rating),
  CONSTRAINT fk_reviews_book
    FOREIGN KEY (book_id) REFERENCES books (book_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_reviews_customer
    FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_reviews_rating CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =====================================================================
-- 3. SAMPLE DATA
-- =====================================================================

-- 11 authors ---------------------------------------------------------
INSERT INTO authors (author_id, full_name, nationality, birth_date, bio, website) VALUES
(1,  'Robert C. Martin', 'American', '1952-12-05',
     'Software engineer and author; co-author of the Agile Manifesto, known for Clean Code and The Clean Coder.', NULL),
(2,  'Erich Gamma', 'Swiss', '1961-03-13',
     'Swiss computer scientist; one of the four authors of Design Patterns and a leader of the Eclipse project.', NULL),
(3,  'Richard Helm', 'American', NULL,
     'Computer scientist and co-author of Design Patterns: Elements of Reusable Object-Oriented Software.', NULL),
(4,  'Ralph Johnson', 'American', NULL,
     'Professor of computer science at the University of Illinois; co-author of Design Patterns and a pioneer of refactoring tools.', NULL),
(5,  'John Vlissides', 'American', '1961-08-02',
     'American computer scientist and co-author of Design Patterns, known for his work on design pattern visualization.', NULL),
(6,  'Andrew Hunt', 'American', NULL,
     'Co-author of The Pragmatic Programmer and one of the original signatories of the Agile Manifesto.', NULL),
(7,  'David Thomas', 'American', NULL,
     'Co-author of The Pragmatic Programmer and a longtime advocate of pragmatic software development.', NULL),
(8,  'J.K. Rowling', 'British', '1965-07-31',
     'British author best known for the Harry Potter series, one of the best-selling book series in history.', NULL),
(9,  'George Orwell', 'British', '1903-06-25',
     'British novelist and essayist, author of Nineteen Eighty-Four and Animal Farm.', NULL),
(10, 'Yuval Noah Harari', 'Israeli', '1976-02-24',
     'Israeli historian and professor, author of Sapiens and Homo Deus.', NULL),
(11, 'Agatha Christie', 'British', '1890-09-15',
     'British writer known as the Queen of Crime, creator of Hercule Poirot and Miss Marple.', NULL);

-- 4 publishers -------------------------------------------------------
INSERT INTO publishers (publisher_id, name, address, city, country, website, email, phone, founded_year) VALUES
(1, 'Penguin Random House', '1745 Broadway', 'New York', 'USA',
    'https://www.penguinrandomhouse.com', 'contact@penguinrandomhouse.com', '+1-212-782-9000', 2013),
(2, 'HarperCollins', '195 Broadway', 'New York', 'USA',
    'https://www.harpercollins.com', 'contact@harpercollins.com', '+1-212-207-7000', 1989),
(3, 'O''Reilly Media', '1005 Gravenstein Highway North', 'Sebastopol', 'USA',
    'https://www.oreilly.com', 'support@oreilly.com', '+1-707-827-7000', 1978),
(4, 'Bloomsbury Publishing', '50 Bedford Square', 'London', 'UK',
    'https://www.bloomsbury.com', 'contact@bloomsbury.com', '+44-20-7631-5600', 1986);

-- 7 categories, two roots with sub-genres ----------------------------
INSERT INTO categories (category_id, name, description, parent_category_id) VALUES
(1, 'Fiction', 'Narrative fiction, including novels, novellas and short story collections.', NULL),
(2, 'Science Fiction', 'Speculative fiction dealing with technology, space, dystopias and alternate futures.', 1),
(3, 'Mystery', 'Crime fiction built around detectives, suspects and the solution of a puzzle.', 1),
(4, 'Fantasy', 'Fiction with magical or supernatural elements, often set in invented worlds.', 1),
(5, 'Non-Fiction', 'Factual writing covering history, science, business and other real-world topics.', NULL),
(6, 'History', 'Non-fiction about past events, periods and societies.', 5),
(7, 'Technology', 'Books about software engineering, programming languages and computing.', 5);

-- 9 books ------------------------------------------------------------
INSERT INTO books (book_id, title, isbn, publisher_id, price, stock, publication_date,
                   language, pages, format, description, cover_image_url) VALUES
(1, 'Clean Code: A Handbook of Agile Software Craftsmanship', '9780132350884', 3, 45.50, 25,
    '2008-08-01', 'English', 464, 'Paperback',
    'A practical guide to writing clean, readable and maintainable code, with case studies and refactoring techniques.',
    'https://example.com/covers/9780132350884.jpg'),
(2, 'Design Patterns: Elements of Reusable Object-Oriented Software', '9780201633610', 3, 59.99, 12,
    '1994-10-31', 'English', 395, 'Hardcover',
    'The catalogue of classic object-oriented design patterns, with intent, structure and consequences for each pattern.',
    'https://example.com/covers/9780201633610.jpg'),
(3, 'The Pragmatic Programmer: Your Journey to Mastery (20th Anniversary Edition)', '9780135957059', 3, 49.95, 30,
    '2019-09-13', 'English', 352, 'Paperback',
    'A modern edition of the classic guide to pragmatic software craftsmanship, from DRY principles to career advice.',
    'https://example.com/covers/9780135957059.jpg'),
(4, 'Harry Potter and the Philosopher''s Stone', '9780747532699', 4, 22.99, 40,
    '1997-06-26', 'English', 223, 'Paperback',
    'The first Harry Potter novel, following a young wizard through his first year at Hogwarts School of Witchcraft and Wizardry.',
    'https://example.com/covers/9780747532699.jpg'),
(5, 'Harry Potter and the Chamber of Secrets', '9780747538493', 4, 23.50, 35,
    '1998-07-02', 'English', 251, 'Paperback',
    'The second Harry Potter novel, in which a mysterious creature warns Harry of danger at Hogwarts.',
    'https://example.com/covers/9780747538493.jpg'),
(6, 'Nineteen Eighty-Four', '9780451524935', 1, 15.99, 50,
    '1961-01-01', 'English', 328, 'Paperback',
    'A dystopian novel about surveillance, propaganda and language under a totalitarian regime.',
    'https://example.com/covers/9780451524935.jpg'),
(7, 'Animal Farm', '9780452284241', 1, 13.50, 45,
    '2004-06-03', 'English', 144, 'Paperback',
    'An allegorical novella about a farm taken over by its animals and the corruption that follows.',
    'https://example.com/covers/9780452284241.jpg'),
(8, 'Sapiens: A Brief History of Humankind', '9780062316097', 2, 28.75, 20,
    '2015-02-10', 'English', 464, 'Hardcover',
    'A sweeping history of humankind, from the cognitive revolution to the present day.',
    'https://example.com/covers/9780062316097.jpg'),
(9, 'The Mysterious Affair at Styles', '9780062073952', 2, 14.25, 18,
    '2012-03-13', 'English', 288, 'Paperback',
    'The first Hercule Poirot mystery, set in an English country house where a wealthy widow is poisoned.',
    'https://example.com/covers/9780062073952.jpg');

-- 13 book-author links (GoF has four authors, Pragmatic has two) ------
INSERT INTO book_authors (book_id, author_id, author_order) VALUES
(1, 1, 1),
(2, 2, 1), (2, 3, 2), (2, 4, 3), (2, 5, 4),
(3, 6, 1), (3, 7, 2),
(4, 8, 1),
(5, 8, 1),
(6, 9, 1),
(7, 9, 1),
(8, 10, 1),
(9, 11, 1);

-- 10 book-category links (Sapiens sits in two categories) ------------
INSERT INTO book_categories (book_id, category_id) VALUES
(1, 7),
(2, 7),
(3, 7),
(4, 4),
(5, 4),
(6, 2),
(7, 1),
(8, 5), (8, 6),
(9, 3);

-- 5 customers (bcrypt hashes, never plaintext passwords) -------------
INSERT INTO customers (customer_id, first_name, last_name, email, password_hash, phone,
                       street_address, city, state_province, postal_code, country, is_active) VALUES
(1, 'An', 'Nguyen', 'an.nguyen@example.com',
    '$2y$10$ff9QlBjA2lDgUugNBPijQGCZoqGszrJxyGPxbgHSFIV0bITmlGc7s',
    '+84 90 123 4567', '12 Le Loi Street, Ben Nghe Ward, District 1', 'Ho Chi Minh City', NULL, '700000', 'Vietnam', 1),
(2, 'Minh', 'Tran', 'minh.tran@example.com',
    '$2y$10$H6nhF7dMWMcaIRZkDoUjvcxWjQkDYpOVT2fD/rUAKzh52rrV8txAY',
    '+84 91 234 5678', '45 Nguyen Hue Street, Hoan Kiem District', 'Hanoi', NULL, '100000', 'Vietnam', 1),
(3, 'Lan', 'Pham', 'lan.pham@example.com',
    '$2y$10$vWRzk1XY2z0U80T7GAGjNxgUf2Ba8mT41mwWj2htQfu9QPCFSTGFD',
    '+84 93 345 6789', '78 Tran Phu Street, Hai Chau District', 'Da Nang', NULL, '550000', 'Vietnam', 1),
(4, 'David', 'Chen', 'david.chen@example.com',
    '$2y$10$Yy6EEvSjWaNOwXNSIZ4ksGPSacexhkYbWWAoGBuaWK7Cqza0p5bKu',
    '+65 8123 4567', '12 Orchard Road, #08-01', 'Singapore', NULL, '238826', 'Singapore', 1),
(5, 'Sofia', 'Garcia', 'sofia.garcia@example.com',
    '$2y$10$ANkWkpMv2BmIk6GpLyqkLc.PVC7IGhc/3GQ7qM7Ic1HGEWyk/fwQZ',
    '+1 212 555 0147', '350 Fifth Avenue, Apt 21B', 'New York', 'NY', '10118', 'USA', 1);

-- 6 orders (customer 1 orders twice; all five statuses represented) --
INSERT INTO orders (order_id, customer_id, order_date, status, payment_method,
                    shipping_fee, total_amount,
                    shipping_address, shipping_city, shipping_state,
                    shipping_postal_code, shipping_country, notes) VALUES
(1, 1, '2026-09-05 10:15:00', 'delivered', 'credit_card', 5.00, 166.39,
    '12 Le Loi Street, Ben Nghe Ward, District 1', 'Ho Chi Minh City', NULL, '700000', 'Vietnam', NULL),
(2, 2, '2026-09-18 14:42:00', 'delivered', 'paypal', 4.50, 133.46,
    '45 Nguyen Hue Street, Hoan Kiem District', 'Hanoi', NULL, '100000', 'Vietnam', NULL),
(3, 3, '2026-10-02 09:05:00', 'shipped', 'bank_transfer', 6.00, 76.75,
    '78 Tran Phu Street, Hai Chau District', 'Da Nang', NULL, '550000', 'Vietnam', NULL),
(4, 4, '2026-10-21 20:30:00', 'processing', 'credit_card', 8.00, 163.44,
    '12 Orchard Road, #08-01', 'Singapore', NULL, '238826', 'Singapore', NULL),
(5, 5, '2026-11-03 11:20:00', 'pending', 'cash_on_delivery', 7.25, 77.24,
    '350 Fifth Avenue, Apt 21B', 'New York', 'NY', '10118', 'USA', NULL),
(6, 1, '2026-11-10 16:05:00', 'cancelled', 'paypal', 5.00, 36.98,
    '12 Le Loi Street, Ben Nghe Ward, District 1', 'Ho Chi Minh City', NULL, '700000', 'Vietnam',
    'Customer cancelled the order before dispatch.');

-- 14 order lines; subtotal is generated, so it is not inserted -------
INSERT INTO order_items (order_id, book_id, quantity, unit_price) VALUES
(1, 1, 1, 45.50),
(1, 3, 2, 49.95),
(1, 6, 1, 15.99),
(2, 2, 1, 59.99),
(2, 4, 3, 22.99),
(3, 8, 1, 28.75),
(3, 9, 2, 14.25),
(3, 7, 1, 13.50),
(4, 1, 1, 45.50),
(4, 2, 1, 59.99),
(4, 3, 1, 49.95),
(5, 5, 2, 23.50),
(5, 4, 1, 22.99),
(6, 6, 2, 15.99);

-- 12 reviews (each customer reviews a book at most once) -------------
INSERT INTO reviews (book_id, customer_id, rating, `comment`, review_date) VALUES
(1, 1, 5, 'The chapter on meaningful names alone is worth the price. Examples are practical and easy to follow.', '2026-09-20 18:30:00'),
(3, 1, 4, 'Great advice on DRY and orthogonality. Some tooling references feel dated, but the mindset still applies.', '2026-10-01 09:10:00'),
(6, 1, 5, 'A chilling and still relevant vision of a totalitarian future. Hard to put down.', '2026-10-15 21:05:00'),
(2, 2, 5, 'The classic catalogue of design patterns. Every pattern comes with trade-offs and real examples.', '2026-10-02 14:00:00'),
(4, 2, 5, 'My kids loved it. The world building is charming and the pacing is perfect for bedtime reading.', '2026-09-30 20:45:00'),
(8, 3, 4, 'A broad and thought provoking overview of human history. Dense in places but always engaging.', '2026-10-20 10:25:00'),
(9, 3, 3, 'A solid first Poirot novel. The reveal is clever, though the middle chapters drag a little.', '2026-10-25 16:40:00'),
(7, 4, 4, 'Short, sharp and devastating. The allegory works on every level.', '2026-09-12 19:15:00'),
(5, 5, 4, 'A worthy sequel that expands the story nicely. Arrived in perfect condition.', '2026-11-12 08:55:00'),
(1, 4, 5, 'I keep this on my desk. The refactoring examples changed how I review code.', '2026-11-08 22:10:00'),
(2, 4, 4, 'Demanding but rewarding. Better as a reference than a cover to cover read.', '2026-11-09 13:35:00'),
(8, 1, 4, 'Fascinating look at how stories and shared myths shaped societies. Recommended.', '2026-10-30 17:20:00');


-- =====================================================================
-- 4. REPORTING VIEW + SANITY CHECKS (useful for the demo video)
-- =====================================================================

-- Recomputes each order total from its line items so the cached
-- orders.total_amount can be audited.
CREATE OR REPLACE VIEW v_order_summary AS
SELECT
  o.order_id,
  o.customer_id,
  CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
  o.order_date,
  o.status,
  COUNT(oi.order_item_id) AS item_count,
  COALESCE(SUM(oi.subtotal), 0.00) AS merchandise_total,
  o.shipping_fee,
  ROUND(COALESCE(SUM(oi.subtotal), 0.00) + o.shipping_fee, 2) AS computed_total,
  o.total_amount AS stored_total
FROM orders AS o
INNER JOIN customers AS c ON c.customer_id = o.customer_id
LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
GROUP BY o.order_id, o.customer_id, c.first_name, c.last_name,
         o.order_date, o.status, o.shipping_fee, o.total_amount;

-- 1) Row count per table (sample data coverage)
SELECT 'authors'        AS table_name, COUNT(*) AS rows_loaded FROM authors
UNION ALL SELECT 'publishers',    COUNT(*) FROM publishers
UNION ALL SELECT 'categories',    COUNT(*) FROM categories
UNION ALL SELECT 'books',         COUNT(*) FROM books
UNION ALL SELECT 'book_authors',  COUNT(*) FROM book_authors
UNION ALL SELECT 'book_categories', COUNT(*) FROM book_categories
UNION ALL SELECT 'customers',     COUNT(*) FROM customers
UNION ALL SELECT 'orders',        COUNT(*) FROM orders
UNION ALL SELECT 'order_items',   COUNT(*) FROM order_items
UNION ALL SELECT 'reviews',       COUNT(*) FROM reviews;

-- 2) Every order total must equal the sum of its lines plus shipping
SELECT order_id,
       stored_total,
       computed_total,
       IF(stored_total = computed_total, 'OK', 'MISMATCH') AS check_result
FROM v_order_summary
ORDER BY order_id;

-- 3) Catalog with all authors and categories of each book
--    (correlated subqueries avoid row fan-out from the two M:N joins)
SELECT b.book_id,
       b.title,
       p.name AS publisher,
       (SELECT GROUP_CONCAT(a.full_name ORDER BY ba.author_order SEPARATOR ', ')
        FROM book_authors AS ba
        INNER JOIN authors AS a ON a.author_id = ba.author_id
        WHERE ba.book_id = b.book_id) AS authors,
       (SELECT GROUP_CONCAT(c.name ORDER BY c.name SEPARATOR ', ')
        FROM book_categories AS bc
        INNER JOIN categories AS c ON c.category_id = bc.category_id
        WHERE bc.book_id = b.book_id) AS categories,
       b.price,
       b.stock
FROM books AS b
INNER JOIN publishers AS p ON p.publisher_id = b.publisher_id
ORDER BY b.book_id;

-- END OF FILE
