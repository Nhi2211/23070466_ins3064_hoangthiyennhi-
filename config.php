<?php
/**
 * INS3064 - Homework 10 : Contact Manager
 * File         : config.php
 * Student Name : Hoang Thi Yen Nhi
 * Student ID   : 23070466
 * Date         : 2026-11-26
 */

declare(strict_types=1);

if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

define('DB_HOST', 'localhost');
define('DB_NAME', 'contact_manager');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_CHARSET', 'utf8mb4');

const ALLOWED_GROUPS = ['Family', 'Friends', 'Work', 'Other', 'General'];

try {
    $dsn = sprintf('mysql:host=%s;dbname=%s;charset=%s', DB_HOST, DB_NAME, DB_CHARSET);
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ]);
} catch (PDOException $e) {
    die('Database connection failed: ' . htmlspecialchars($e->getMessage(), ENT_QUOTES, 'UTF-8'));
}

function e(?string $value): string
{
    return htmlspecialchars((string) $value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function setFlash(string $type, string $message): void
{
    $_SESSION['flash'] = [
        'type'    => $type,
        'message' => $message,
    ];
}

function renderHeader(string $pageTitle = 'Contact Manager'): void
{
    $flash = $_SESSION['flash'] ?? null;
    unset($_SESSION['flash']);
    ?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= e($pageTitle) ?> · INS3064</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">
    <header class="topbar">
        <div>
            <h1><a href="index.php">Contact Manager</a></h1>
            <p class="subtitle">INS3064 · Session 10 — PHP PDO &amp; MySQL CRUD</p>
        </div>
        <nav class="nav-actions">
            <a href="index.php" class="btn btn-secondary">All Contacts</a>
            <a href="add.php" class="btn btn-primary">+ Add New Contact</a>
        </nav>
    </header>

    <?php if (is_array($flash) && !empty($flash['message'])): ?>
        <div class="flash flash-<?= e($flash['type'] ?? 'success') ?>" role="status">
            <?= e($flash['message']) ?>
        </div>
    <?php endif; ?>
    <?php
}

function renderFooter(): void
{
    ?>
    <footer class="footer">
        <p>Contact Manager · Hoang Thi Yen Nhi (23070466) · INS3064 Web Development</p>
    </footer>
</div>
</body>
</html>
    <?php
}