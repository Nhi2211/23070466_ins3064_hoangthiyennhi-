<?php
/**
 * INS3064 - Homework 10 : Contact Manager
 * File         : add.php (Create New Contact)
 * Student Name : Hoang Thi Yen Nhi
 * Student ID   : 23070466
 * Date         : 2026-11-26
 */

declare(strict_types=1);
require_once __DIR__ . '/config.php';

$errors = [];
$name = '';
$email = '';
$phone = '';
$groupName = 'General';
$notes = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name      = trim((string) (filter_input(INPUT_POST, 'name', FILTER_UNSAFE_RAW) ?? ''));
    $email     = trim((string) (filter_input(INPUT_POST, 'email', FILTER_UNSAFE_RAW) ?? ''));
    $phone     = trim((string) (filter_input(INPUT_POST, 'phone', FILTER_UNSAFE_RAW) ?? ''));
    $groupName = trim((string) (filter_input(INPUT_POST, 'group_name', FILTER_UNSAFE_RAW) ?? 'General'));
    $notes     = trim((string) (filter_input(INPUT_POST, 'notes', FILTER_UNSAFE_RAW) ?? ''));

    // Validate Name
    if ($name === '') {
        $errors[] = 'Name is required and cannot be empty.';
    } elseif (mb_strlen($name) > 100) {
        $errors[] = 'Name must not exceed 100 characters.';
    }

    // Validate Email (required, valid format, unique)
    if ($email === '') {
        $errors[] = 'Email is required.';
    } elseif (filter_var($email, FILTER_VALIDATE_EMAIL) === false) {
        $errors[] = 'Please enter a valid email address.';
    } elseif (mb_strlen($email) > 150) {
        $errors[] = 'Email must not exceed 150 characters.';
    } else {
        $checkStmt = $pdo->prepare('SELECT COUNT(*) FROM contacts WHERE email = :email');
        $checkStmt->execute([':email' => $email]);
        if ((int) $checkStmt->fetchColumn() > 0) {
            $errors[] = 'This email address already exists in your contacts.';
        }
    }

    // Validate Phone
    if ($phone !== '' && mb_strlen($phone) > 20) {
        $errors[] = 'Phone number must not exceed 20 characters.';
    }

    // Validate Group
    if (!in_array($groupName, ALLOWED_GROUPS, true)) {
        $groupName = 'General';
    }

    if (empty($errors)) {
        $insertStmt = $pdo->prepare(
            'INSERT INTO contacts (name, email, phone, group_name, notes)
             VALUES (:name, :email, :phone, :group_name, :notes)'
        );
        $insertStmt->execute([
            ':name'       => $name,
            ':email'      => $email,
            ':phone'      => $phone !== '' ? $phone : null,
            ':group_name' => $groupName,
            ':notes'      => $notes !== '' ? $notes : null,
        ]);

        setFlash('success', 'Contact "' . $name . '" added successfully!');
        header('Location: index.php');
        exit;
    }
}

renderHeader('Add New Contact');
?>

<section class="card form-card">
    <h2>Add New Contact</h2>

    <?php if (!empty($errors)): ?>
        <div class="flash flash-error" role="alert">
            <strong>Please fix the following errors:</strong>
            <ul class="error-list">
                <?php foreach ($errors as $error): ?>
                    <li><?= e($error) ?></li>
                <?php endforeach; ?>
            </ul>
        </div>
    <?php endif; ?>

    <form method="post" action="add.php" novalidate>
        <div class="form-group">
            <label for="name">Name <span class="required">*</span></label>
            <input type="text" id="name" name="name" maxlength="100" required value="<?= e($name) ?>" placeholder="e.g. Nguyen Van A">
        </div>

        <div class="form-group">
            <label for="email">Email <span class="required">*</span></label>
            <input type="email" id="email" name="email" maxlength="150" required value="<?= e($email) ?>" placeholder="e.g. nguyenvana@example.com">
        </div>

        <div class="form-row">
            <div class="form-group">
                <label for="phone">Phone</label>
                <input type="text" id="phone" name="phone" maxlength="20" value="<?= e($phone) ?>" placeholder="e.g. 0912345678">
            </div>

            <div class="form-group">
                <label for="group_name">Group</label>
                <select id="group_name" name="group_name">
                    <?php foreach (ALLOWED_GROUPS as $group): ?>
                        <option value="<?= e($group) ?>" <?= $groupName === $group ? 'selected' : '' ?>>
                            <?= e($group) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>
        </div>

        <div class="form-group">
            <label for="notes">Notes</label>
            <textarea id="notes" name="notes" rows="4" placeholder="Optional notes about this contact..."><?= e($notes) ?></textarea>
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-primary">Save Contact</button>
            <a href="index.php" class="btn btn-secondary">Cancel</a>
        </div>
    </form>
</section>

<?php renderFooter(); ?>