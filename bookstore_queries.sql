-- =====================================================================
--  INS3064 - Homework 7 : Advanced SQL Queries
--  Student    : [Your Full Name]
--  Student ID : [Your Student ID]
--  Assignment : Homework 7
--  Date       : 2026-11-15
--  Database   : bookstore_db (schema created by Homework 6 bookstore_db.sql)
--  RDBMS      : MySQL 8.0+ / MariaDB 10.4+
-- ---------------------------------------------------------------------
--  HOW TO RUN
--    1. Import bookstore_db.sql first (it creates bookstore_db).
--    2. Run this file in phpMyAdmin > SQL tab, or:
--         mysql -u root -p < bookstore_queries.sql
--    3. Query 9 creates the view v_book_sales_summary and then selects
--       from it. CREATE OR REPLACE makes the file safe to re-run.
--
--  TECHNIQUES USED
--    Q1  INNER JOIN (3 tables)
--    Q2  INNER JOIN (4 tables) + ORDER BY
--    Q3  JOIN (4 tables) + GROUP_CONCAT + LEFT JOIN
--    Q4  LEFT JOIN + GROUP BY + aggregate functions
--    Q5  LEFT JOIN + GROUP BY + zero-order handling with COALESCE
--    Q6  Scalar subquery in WHERE
--    Q7  Nested subquery with ALL (tie handling, no LIMIT)
--    Q8  WHERE + GROUP BY + HAVING
--    Q9  VIEW with pre-aggregated derived tables + COALESCE
--    Q10 Derived table + UNION ALL + LEFT JOIN + GROUP BY + date functions
--
--  NOTE ON EXPECTED OUTPUT
--    The result tables below were captured by running this file against
--    the Homework 6 sample data on 2026-11-15. Revenue figures use the
--    order line subtotals (quantity * unit_price); shipping fees are not
--    allocated to individual items.
-- =====================================================================

USE bookstore_db;


-- =====================================================================
-- Query 1 : Books with Authors
-- Lists every book with each of its authors, one row per book-author
-- pair. A book with several authors therefore appears several times.
-- Ordered by book title, then by the author position on the cover.
-- =====================================================================
SELECT b.title,
       b.isbn,
       a.full_name AS author_name
FROM books AS b
INNER JOIN book_authors AS ba ON ba.book_id = b.book_id
INNER JOIN authors AS a ON a.author_id = ba.author_id
ORDER BY b.title, ba.author_order;

/*
Expected output (13 rows):

| title                                                                        | isbn          | author_name       |
|------------------------------------------------------------------------------|---------------|-------------------|
| Animal Farm                                                                  | 9780452284241 | George Orwell     |
| Clean Code: A Handbook of Agile Software Craftsmanship                       | 9780132350884 | Robert C. Martin  |
| Design Patterns: Elements of Reusable Object-Oriented Software               | 9780201633610 | Erich Gamma       |
| Design Patterns: Elements of Reusable Object-Oriented Software               | 9780201633610 | Richard Helm      |
| Design Patterns: Elements of Reusable Object-Oriented Software               | 9780201633610 | Ralph Johnson     |
| Design Patterns: Elements of Reusable Object-Oriented Software               | 9780201633610 | John Vlissides    |
| Harry Potter and the Chamber of Secrets                                      | 9780747538493 | J.K. Rowling      |
| Harry Potter and the Philosopher's Stone                                     | 9780747532699 | J.K. Rowling      |
| Nineteen Eighty-Four                                                         | 9780451524935 | George Orwell     |
| Sapiens: A Brief History of Humankind                                        | 9780062316097 | Yuval Noah Harari |
| The Mysterious Affair at Styles                                              | 9780062073952 | Agatha Christie   |
| The Pragmatic Programmer: Your Journey to Mastery (20th Anniversary Edition) | 9780135957059 | Andrew Hunt       |
| The Pragmatic Programmer: Your Journey to Mastery (20th Anniversary Edition) | 9780135957059 | David Thomas      |

Design Patterns has 4 authors, so it appears 4 times; The Pragmatic
Programmer has 2 authors, so it appears twice.
*/


-- =====================================================================
-- Query 2 : Order Details
-- One row per order line with the customer name, order date, book title,
-- quantity and line total. Newest orders appear first; lines inside the
-- same order keep their original order_item_id order.
-- line_total uses the generated subtotal column (= quantity * unit_price).
-- =====================================================================
SELECT o.order_id,
       CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       o.order_date,
       b.title,
       oi.quantity,
       oi.subtotal AS line_total
FROM orders AS o
INNER JOIN customers AS c ON c.customer_id = o.customer_id
INNER JOIN order_items AS oi ON oi.order_id = o.order_id
INNER JOIN books AS b ON b.book_id = oi.book_id
ORDER BY o.order_date DESC, o.order_id DESC, oi.order_item_id;

/*
Expected output (14 rows):

| order_id | customer_name | order_date          | title                                                                        | quantity | line_total |
|----------|---------------|---------------------|------------------------------------------------------------------------------|----------|------------|
|        6 | An Nguyen     | 2026-11-10 16:05:00 | Nineteen Eighty-Four                                                         |        2 |      31.98 |
|        5 | Sofia Garcia  | 2026-11-03 11:20:00 | Harry Potter and the Chamber of Secrets                                      |        2 |      47.00 |
|        5 | Sofia Garcia  | 2026-11-03 11:20:00 | Harry Potter and the Philosopher's Stone                                     |        1 |      22.99 |
|        4 | David Chen    | 2026-10-21 20:30:00 | Clean Code: A Handbook of Agile Software Craftsmanship                       |        1 |      45.50 |
|        4 | David Chen    | 2026-10-21 20:30:00 | Design Patterns: Elements of Reusable Object-Oriented Software               |        1 |      59.99 |
|        4 | David Chen    | 2026-10-21 20:30:00 | The Pragmatic Programmer: Your Journey to Mastery (20th Anniversary Edition) |        1 |      49.95 |
|        3 | Lan Pham      | 2026-10-02 09:05:00 | Sapiens: A Brief History of Humankind                                        |        1 |      28.75 |
|        3 | Lan Pham      | 2026-10-02 09:05:00 | The Mysterious Affair at Styles                                              |        2 |      28.50 |
|        3 | Lan Pham      | 2026-10-02 09:05:00 | Animal Farm                                                                  |        1 |      13.50 |
|        2 | Minh Tran     | 2026-09-18 14:42:00 | Design Patterns: Elements of Reusable Object-Oriented Software               |        1 |      59.99 |
|        2 | Minh Tran     | 2026-09-18 14:42:00 | Harry Potter and the Philosopher's Stone                                     |        3 |      68.97 |
|        1 | An Nguyen     | 2026-09-05 10:15:00 | Clean Code: A Handbook of Agile Software Craftsmanship                       |        1 |      45.50 |
|        1 | An Nguyen     | 2026-09-05 10:15:00 | The Pragmatic Programmer: Your Journey to Mastery (20th Anniversary Edition) |        2 |      99.90 |
|        1 | An Nguyen     | 2026-09-05 10:15:00 | Nineteen Eighty-Four                                                         |        1 |      15.99 |
*/


-- =====================================================================
-- Query 3 : Books with Publisher and Categories
-- One row per book with its publisher name and all of its category
-- names, comma-separated. Four tables are joined; LEFT JOIN on the
-- category side keeps books that have no category (they show "(none)").
-- GROUP_CONCAT is the string aggregation technique.
-- =====================================================================
SELECT b.title,
       p.name AS publisher_name,
       COALESCE(GROUP_CONCAT(c.name ORDER BY c.name SEPARATOR ', '), '(none)') AS categories
FROM books AS b
INNER JOIN publishers AS p ON p.publisher_id = b.publisher_id
LEFT JOIN book_categories AS bc ON bc.book_id = b.book_id
LEFT JOIN categories AS c ON c.category_id = bc.category_id
GROUP BY b.book_id, b.title, p.name
ORDER BY b.title;

/*
Expected output (9 rows):

| title                                                                        | publisher_name        | categories           |
|------------------------------------------------------------------------------|-----------------------|----------------------|
| Animal Farm                                                                  | Penguin Random House  | Fiction              |
| Clean Code: A Handbook of Agile Software Craftsmanship                       | O'Reilly Media        | Technology           |
| Design Patterns: Elements of Reusable Object-Oriented Software               | O'Reilly Media        | Technology           |
| Harry Potter and the Chamber of Secrets                                      | Bloomsbury Publishing | Fantasy              |
| Harry Potter and the Philosopher's Stone                                     | Bloomsbury Publishing | Fantasy              |
| Nineteen Eighty-Four                                                         | Penguin Random House  | Science Fiction      |
| Sapiens: A Brief History of Humankind                                        | HarperCollins         | History, Non-Fiction |
| The Mysterious Affair at Styles                                              | HarperCollins         | Mystery              |
| The Pragmatic Programmer: Your Journey to Mastery (20th Anniversary Edition) | O'Reilly Media        | Technology           |

Sapiens belongs to two categories, so its categories cell contains both.
*/


-- =====================================================================
-- Query 4 : Sales by Book
-- For every book, total copies sold and total revenue, highest revenue
-- first. LEFT JOIN keeps books with no sales, which show 0 / 0.00.
-- =====================================================================
SELECT b.title,
       COALESCE(SUM(oi.quantity), 0) AS total_quantity_sold,
       COALESCE(SUM(oi.subtotal), 0.00) AS total_revenue
FROM books AS b
LEFT JOIN order_items AS oi ON oi.book_id = b.book_id
GROUP BY b.book_id, b.title
ORDER BY total_revenue DESC, b.title;

/*
Expected output (9 rows):

| title                                                                        | total_quantity_sold | total_revenue |
|------------------------------------------------------------------------------|---------------------|---------------|
| The Pragmatic Programmer: Your Journey to Mastery (20th Anniversary Edition) |                   3 |        149.85 |
| Design Patterns: Elements of Reusable Object-Oriented Software               |                   2 |        119.98 |
| Harry Potter and the Philosopher's Stone                                     |                   4 |         91.96 |
| Clean Code: A Handbook of Agile Software Craftsmanship                       |                   2 |         91.00 |
| Nineteen Eighty-Four                                                         |                   3 |         47.97 |
| Harry Potter and the Chamber of Secrets                                      |                   2 |         47.00 |
| Sapiens: A Brief History of Humankind                                        |                   1 |         28.75 |
| The Mysterious Affair at Styles                                              |                   2 |         28.50 |
| Animal Farm                                                                  |                   1 |         13.50 |

Harry Potter and the Philosopher's Stone sold the most copies (4) while
The Pragmatic Programmer earned the most revenue (149.85).
*/


-- =====================================================================
-- Query 5 : Customer Order Summary
-- Number of orders and total amount spent per customer. LEFT JOIN makes
-- sure customers with zero orders still appear (they would show 0 and
-- 0.00); the sample data happens to give every customer at least one
-- order. COALESCE replaces the NULL that SUM returns for no rows.
-- =====================================================================
SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(o.order_id) AS number_of_orders,
       COALESCE(SUM(o.total_amount), 0.00) AS total_amount_spent
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_amount_spent DESC, customer_name;

/*
Expected output (5 rows):

| customer_name | number_of_orders | total_amount_spent |
|---------------|------------------|--------------------|
| An Nguyen     |                2 |             203.37 |
| David Chen    |                1 |             163.44 |
| Minh Tran     |                1 |             133.46 |
| Sofia Garcia  |                1 |              77.24 |
| Lan Pham      |                1 |              76.75 |

An Nguyen placed two orders (166.39 + 36.98 = 203.37).
If a customer had no orders, the LEFT JOIN would still return one row
with number_of_orders = 0 and total_amount_spent = 0.00.
*/


-- =====================================================================
-- Query 6 : Books Above Average Price
-- Lists books whose price is higher than the average price of all books.
-- The average is computed by a scalar subquery, so the value is not
-- hard-coded. With the sample data AVG(price) = 30.49.
-- =====================================================================
SELECT b.title,
       b.price
FROM books AS b
WHERE b.price > (SELECT AVG(price) FROM books)
ORDER BY b.price DESC;

/*
Expected output (3 rows):

| title                                                                        | price |
|------------------------------------------------------------------------------|-------|
| Design Patterns: Elements of Reusable Object-Oriented Software               | 59.99 |
| The Pragmatic Programmer: Your Journey to Mastery (20th Anniversary Edition) | 49.95 |
| Clean Code: A Handbook of Agile Software Craftsmanship                       | 45.50 |

The catalog average is 274.42 / 9 = 30.49, so these three books qualify.
*/


-- =====================================================================
-- Query 7 : Best-Selling Author
-- Finds the author whose books sold the most copies. A co-author is
-- credited with the full quantity of each book they contributed to.
-- The HAVING ... >= ALL subquery compares every author total against
-- every other total, so if several authors tie at the top they are all
-- returned (this is why LIMIT is not used).
-- =====================================================================
SELECT a.full_name AS author_name,
       SUM(oi.quantity) AS total_quantity_sold
FROM authors AS a
INNER JOIN book_authors AS ba ON ba.author_id = a.author_id
INNER JOIN order_items AS oi ON oi.book_id = ba.book_id
GROUP BY a.author_id, a.full_name
HAVING SUM(oi.quantity) >= ALL (
    SELECT SUM(oi2.quantity)
    FROM book_authors AS ba2
    INNER JOIN order_items AS oi2 ON oi2.book_id = ba2.book_id
    GROUP BY ba2.author_id
)
ORDER BY total_quantity_sold DESC, author_name;

/*
Expected output (1 row):

| author_name  | total_quantity_sold |
|--------------|---------------------|
| J.K. Rowling |                   6 |

J.K. Rowling sold 4 copies of Harry Potter and the Philosopher's Stone
plus 2 copies of Harry Potter and the Chamber of Secrets.
Second place is George Orwell with 4 (Nineteen Eighty-Four 3 + Animal Farm 1).
If two authors had finished level on 6, both rows would be returned.
*/


-- =====================================================================
-- Query 8 : Prolific Reviewers
-- Customers who wrote more than 2 reviews with a rating of 3 or higher.
-- WHERE filters the individual reviews before grouping; HAVING filters
-- the grouped result. Both conditions are required.
-- =====================================================================
SELECT CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       COUNT(r.review_id) AS review_count
FROM customers AS c
INNER JOIN reviews AS r ON r.customer_id = c.customer_id
WHERE r.rating >= 3
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(r.review_id) > 2
ORDER BY review_count DESC, customer_name;

/*
Expected output (2 rows):

| customer_name | review_count |
|---------------|--------------|
| An Nguyen     |            4 |
| David Chen    |            3 |

An Nguyen wrote 4 qualifying reviews; David Chen wrote 3.
Minh Tran and Lan Pham each wrote 2, so HAVING excludes them.
*/


-- =====================================================================
-- Query 9 : Book Sales Summary View
-- Creates v_book_sales_summary with title, ISBN, publisher, quantity
-- sold, revenue, average rating and review count. Sales and reviews are
-- pre-aggregated in separate derived tables; joining both directly to
-- books would multiply rows (fan-out) and inflate the totals.
-- COALESCE shows 0 for no sales / no reviews; the average rating stays
-- NULL when a book has no reviews, which is the appropriate unknown value.
-- A SELECT from the view follows so the result can be verified.
-- =====================================================================
CREATE OR REPLACE VIEW v_book_sales_summary AS
SELECT b.title,
       b.isbn,
       p.name AS publisher_name,
       COALESCE(s.total_quantity_sold, 0) AS total_quantity_sold,
       COALESCE(s.total_revenue, 0.00) AS total_revenue,
       r.average_review_rating,
       COALESCE(r.review_count, 0) AS review_count
FROM books AS b
INNER JOIN publishers AS p ON p.publisher_id = b.publisher_id
LEFT JOIN (
    SELECT book_id,
           SUM(quantity) AS total_quantity_sold,
           SUM(subtotal) AS total_revenue
    FROM order_items
    GROUP BY book_id
) AS s ON s.book_id = b.book_id
LEFT JOIN (
    SELECT book_id,
           ROUND(AVG(rating), 2) AS average_review_rating,
           COUNT(*) AS review_count
    FROM reviews
    GROUP BY book_id
) AS r ON r.book_id = b.book_id;

SELECT title,
       isbn,
       publisher_name,
       total_quantity_sold,
       total_revenue,
       average_review_rating,
       review_count
FROM v_book_sales_summary
ORDER BY total_revenue DESC, title;

/*
Expected output (9 rows):

| title                                                                        | isbn          | publisher_name        | total_quantity_sold | total_revenue | average_review_rating | review_count |
|------------------------------------------------------------------------------|---------------|-----------------------|---------------------|---------------|-----------------------|--------------|
| The Pragmatic Programmer: Your Journey to Mastery (20th Anniversary Edition) | 9780135957059 | O'Reilly Media        |                   3 |        149.85 |                  4.00 |            1 |
| Design Patterns: Elements of Reusable Object-Oriented Software               | 9780201633610 | O'Reilly Media        |                   2 |        119.98 |                  4.50 |            2 |
| Harry Potter and the Philosopher's Stone                                     | 9780747532699 | Bloomsbury Publishing |                   4 |         91.96 |                  5.00 |            1 |
| Clean Code: A Handbook of Agile Software Craftsmanship                       | 9780132350884 | O'Reilly Media        |                   2 |         91.00 |                  5.00 |            2 |
| Nineteen Eighty-Four                                                         | 9780451524935 | Penguin Random House  |                   3 |         47.97 |                  5.00 |            1 |
| Harry Potter and the Chamber of Secrets                                      | 9780747538493 | Bloomsbury Publishing |                   2 |         47.00 |                  4.00 |            1 |
| Sapiens: A Brief History of Humankind                                        | 9780062316097 | HarperCollins         |                   1 |         28.75 |                  4.00 |            2 |
| The Mysterious Affair at Styles                                              | 9780062073952 | HarperCollins         |                   2 |         28.50 |                  3.00 |            1 |
| Animal Farm                                                                  | 9780452284241 | Penguin Random House  |                   1 |         13.50 |                  4.00 |            1 |

All sample books have at least one sale and one review. A book without
sales would show total_quantity_sold = 0 and total_revenue = 0.00; a book
without reviews would show review_count = 0 and average_review_rating = NULL.
*/


-- =====================================================================
-- Query 10 : Monthly Revenue Report
-- Revenue for every month of the current year, including months with no
-- orders. The 12-month calendar is built with a derived table and
-- UNION ALL, then LEFT JOINed to orders and order_items, so empty months
-- survive the join. COUNT(DISTINCT order_id) counts orders once even
-- when they contain several lines. Revenue is merchandise revenue
-- (order line subtotals); shipping is not allocated per item.
-- Sample data is in 2026, which is the current year at the time of
-- writing; in a different year the report returns 12 zero rows.
-- =====================================================================
SELECT m.month_number,
       m.month_name,
       COUNT(DISTINCT o.order_id) AS number_of_orders,
       COALESCE(SUM(oi.quantity), 0) AS total_items_sold,
       COALESCE(SUM(oi.subtotal), 0.00) AS total_revenue
FROM (
    SELECT 1 AS month_number, 'January' AS month_name
    UNION ALL SELECT 2,  'February'
    UNION ALL SELECT 3,  'March'
    UNION ALL SELECT 4,  'April'
    UNION ALL SELECT 5,  'May'
    UNION ALL SELECT 6,  'June'
    UNION ALL SELECT 7,  'July'
    UNION ALL SELECT 8,  'August'
    UNION ALL SELECT 9,  'September'
    UNION ALL SELECT 10, 'October'
    UNION ALL SELECT 11, 'November'
    UNION ALL SELECT 12, 'December'
) AS m
LEFT JOIN orders AS o
       ON MONTH(o.order_date) = m.month_number
      AND YEAR(o.order_date) = YEAR(CURDATE())
LEFT JOIN order_items AS oi ON oi.order_id = o.order_id
GROUP BY m.month_number, m.month_name
ORDER BY m.month_number;

/*
Expected output (12 rows):

| month_number | month_name | number_of_orders | total_items_sold | total_revenue |
|--------------|------------|------------------|------------------|---------------|
|            1 | January    |                0 |                0 |          0.00 |
|            2 | February   |                0 |                0 |          0.00 |
|            3 | March      |                0 |                0 |          0.00 |
|            4 | April      |                0 |                0 |          0.00 |
|            5 | May        |                0 |                0 |          0.00 |
|            6 | June       |                0 |                0 |          0.00 |
|            7 | July       |                0 |                0 |          0.00 |
|            8 | August     |                0 |                0 |          0.00 |
|            9 | September  |                2 |                8 |        290.35 |
|           10 | October    |                2 |                7 |        226.19 |
|           11 | November   |                2 |                5 |        101.97 |
|           12 | December   |                0 |                0 |          0.00 |

September: orders 1 and 2 (161.39 + 128.96 = 290.35).
October:   orders 3 and 4 (70.75 + 155.44 = 226.19).
November:  orders 5 and 6 (69.99 + 31.98 = 101.97).
The year total is 618.51, matching Query 4's revenue sum.
*/

-- END OF FILE
