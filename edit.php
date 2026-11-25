<?php
/**
 * INS3064 - Homework 10 : Contact Manager
 * File         : edit.php (Update Existing Contact)
 * Student Name : Hoang Thi Yen Nhi
 * Student ID   : 23070466
 * Date         : 2026-11-26
 */

declare(strict_types=1);
require_once __DIR__ . '/config.php';

$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $postId = filter_input(INPUT_POST, 'id', FILTER_VALIDATE_INT);
    if ($postId !== false && $postId !== null) {
        $id = $postId;
    }
}

$contact = null;
if ($id !== false && $id !== null && $id > 0) {
    $stmt = $pdo->prepare('SELECT id, name, email, phone, group_name, notes FROM contacts WHERE id = :id');
    $stmt->execute([':id' => $id]);
    $contact = $stmt->fetch();
}

if (!$contact) {
    renderHeader('Contact Not Found');
    ?>
    <section class="card form-card">
        <div class="flash flash-error">Contact not found. The requested record does not exist.</div>
        <a href="index.php" class="btn btn-primary">&larr; Back to Contacts</a>
    </section>
    <?php
    renderFooter();
    exit;
}

$errors = [];
$name      = (string) $contact['name'];
$email     = (string) ($contact['email'] ?? '');
$phone     = (string) ($contact['phone'] ?? '');
$groupName = (string) ($contact['group_name'] ?? 'General');
$notes     = (string) ($contact['notes'] ?? '');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name      = trim((string) (filter_input(INPUT_POST, 'name', FILTER_UNSAFE_RAW) ?? ''));
    $email     = trim((string) (filter_input(INPUT_POST, 'email', FILTER_UNSAFE_RAW) ?? ''));
    $phone     = trim((string) (filter_input(INPUT_POST, 'phone', FILTER_UNSAFE_RAW) ?? ''));
    $groupName = trim((string) (filter_input(INPUT_POST, 'group_name', FILTER_UNSAFE_RAW) ?? 'General'));
    $notes     = trim((string) (filter_input(INPUT_POST, 'notes', FILTER_UNSAFE_RAW) ?? ''));

    if ($name === '') {
        $errors[] = 'Name is required and cannot be empty.';
    } elseif (mb_strlen($name) > 100) {
        $errors[] = 'Name must not exceed 100 characters.';
    }

    if ($email === '') {
        $errors[] = 'Email is required.';
    } elseif (filter_var($email, FILTER_VALIDATE_EMAIL) === false) {
        $errors[] = 'Please enter a valid email address.';
    } elseif (mb_strlen($email) > 150) {
        $errors[] = 'Email must not exceed 150 characters.';
    } else {
        $checkStmt = $pdo->prepare('SELECT COUNT(*) FROM contacts WHERE email = :email AND id != :id');
        $checkStmt->execute([
            ':email' => $email,
            ':id'    => (int) $contact['id'],
        ]);
        if ((int) $checkStmt->fetchColumn() > 0) {
            $errors[] = 'Another contact is already using this email address.';
        }
    }

    if ($phone !== '' && mb_strlen($phone) > 20) {
        $errors[] = 'Phone number must not exceed 20 characters.';
    }

    if (!in_array($groupName, ALLOWED_GROUPS, true)) {
        $groupName = 'General';
    }

    if (empty($errors)) {
        $updateStmt = $pdo->prepare(
            'UPDATE contacts
             SET name = :name,
                 email = :email,
                 phone = :phone,
                 group_name = :group_name,
                 notes = :notes
             WHERE id = :id'
        );
        $updateStmt->execute([
            ':name'       => $name,
            ':email'      => $email,
            ':phone'      => $phone !== '' ? $phone : null,
            ':group_name' => $groupName,
            ':notes'      => $notes !== '' ? $notes : null,
            ':id'         => (int) $contact['id'],
        ]);

        setFlash('success', 'Contact "' . $name . '" updated successfully!');
        header('Location: index.php');
        exit;
    }
}

renderHeader('Edit Contact');
?>

<section class="card form-card">
    <h2>Edit Contact #<?= (int) $contact['id'] ?></h2>

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

    <form method="post" action="edit.php?id=<?= (int) $contact['id'] ?>" novalidate>
        <input type="hidden" name="id" value="<?= (int) $contact['id'] ?>">

        <div class="form-group">
            <label for="name">Name <span class="required">*</span></label>
            <input type="text" id="name" name="name" maxlength="100" required value="<?= e($name) ?>">
        </div>

        <div class="form-group">
            <label for="email">Email <span class="required">*</span></label>
            <input type="email" id="email" name="email" maxlength="150" required value="<?= e($email) ?>">
        </div>

        <div class="form-row">
            <div class="form-group">
                <label for="phone">Phone</label>
                <input type="text" id="phone" name="phone" maxlength="20" value="<?= e($phone) ?>">
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
            <textarea id="notes" name="notes" rows="4"><?= e($notes) ?></textarea>
        </div>

        <div class="form-actions">
            <button type="submit" class="btn btn-primary">Update Contact</button>
            <a href="index.php" class="btn btn-secondary">Cancel</a>
        </div>
    </form>
</section>

<?php renderFooter(); ?>