<?php
/**
 * INS3064 - Homework 10 : Contact Manager
 * File         : delete.php (Confirm & Delete Contact)
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
    $stmt = $pdo->prepare('SELECT id, name, email, phone, group_name, notes, created_at FROM contacts WHERE id = :id');
    $stmt->execute([':id' => $id]);
    $contact = $stmt->fetch();
}

if (!$contact) {
    renderHeader('Contact Not Found');
    ?>
    <section class="card form-card">
        <div class="flash flash-error">Contact not found. It may have already been deleted.</div>
        <a href="index.php" class="btn btn-primary">&larr; Back to Contacts</a>
    </section>
    <?php
    renderFooter();
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $deleteStmt = $pdo->prepare('DELETE FROM contacts WHERE id = :id');
    $deleteStmt->execute([':id' => (int) $contact['id']]);

    setFlash('success', 'Contact "' . $contact['name'] . '" deleted successfully!');
    header('Location: index.php');
    exit;
}

renderHeader('Delete Contact');
?>

<section class="card form-card confirm-card">
    <h2>Delete Contact</h2>
    <p class="confirm-warning">Are you sure you want to delete this contact? This action cannot be undone.</p>

    <dl class="detail-list">
        <dt>Name</dt>
        <dd><?= e($contact['name']) ?></dd>

        <dt>Email</dt>
        <dd><?= e($contact['email'] ?: '—') ?></dd>

        <dt>Phone</dt>
        <dd><?= e($contact['phone'] ?: '—') ?></dd>

        <dt>Group</dt>
        <dd><?= e($contact['group_name']) ?></dd>

        <dt>Notes</dt>
        <dd><?= e($contact['notes'] ?: '—') ?></dd>
    </dl>

    <form method="post" action="delete.php?id=<?= (int) $contact['id'] ?>" class="form-actions">
        <input type="hidden" name="id" value="<?= (int) $contact['id'] ?>">
        <button type="submit" class="btn btn-danger">Yes, Delete Contact</button>
        <a href="index.php" class="btn btn-secondary">Cancel</a>
    </form>
</section>

<?php renderFooter(); ?>