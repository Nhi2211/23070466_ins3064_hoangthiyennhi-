<?php
/**
 * INS3064 - Homework 10 : Contact Manager
 * File         : index.php (List, Search & Sort Contacts)
 * Student Name : Hoang Thi Yen Nhi
 * Student ID   : 23070466
 * Date         : 2026-11-26
 */

declare(strict_types=1);
require_once __DIR__ . '/config.php';

$search = trim((string) (filter_input(INPUT_GET, 'search', FILTER_UNSAFE_RAW) ?? ''));

$allowedSortColumns = [
    'name'       => 'name',
    'email'      => 'email',
    'phone'      => 'phone',
    'group_name' => 'group_name',
    'created_at' => 'created_at',
];

$sortParam = (string) (filter_input(INPUT_GET, 'sort', FILTER_UNSAFE_RAW) ?? 'created_at');
$sortColumn = $allowedSortColumns[$sortParam] ?? 'created_at';

$dirParam = strtoupper((string) (filter_input(INPUT_GET, 'dir', FILTER_UNSAFE_RAW) ?? 'DESC'));
$sortDir = ($dirParam === 'ASC') ? 'ASC' : 'DESC';

// Total contacts in database
$totalContacts = (int) $pdo->query('SELECT COUNT(*) FROM contacts')->fetchColumn();

if ($search !== '') {
    $sql = "SELECT id, name, email, phone, group_name, notes, created_at
            FROM contacts
            WHERE name LIKE :search_name OR email LIKE :search_email
            ORDER BY {$sortColumn} {$sortDir}, id DESC";
    $stmt = $pdo->prepare($sql);
    $likePattern = '%' . $search . '%';
    $stmt->execute([
        ':search_name'  => $likePattern,
        ':search_email' => $likePattern,
    ]);
} else {
    $sql = "SELECT id, name, email, phone, group_name, notes, created_at
            FROM contacts
            ORDER BY {$sortColumn} {$sortDir}, id DESC";
    $stmt = $pdo->prepare($sql);
    $stmt->execute();
}

$contacts = $stmt->fetchAll();

function sortLink(string $column, string $label, string $currentSort, string $currentDir, string $search): string
{
    $nextDir = ($currentSort === $column && $currentDir === 'ASC') ? 'DESC' : 'ASC';
    $indicator = '';
    if ($currentSort === $column) {
        $indicator = $currentDir === 'ASC' ? ' ▲' : ' ▼';
    }
    $query = http_build_query([
        'search' => $search,
        'sort'   => $column,
        'dir'    => $nextDir,
    ]);
    return '<a href="index.php?' . e($query) . '" class="sort-link">' . e($label . $indicator) . '</a>';
}

renderHeader('All Contacts');
?>

<section class="card">
    <div class="toolbar">
        <div class="stats">
            Total Contacts: <strong><?= $totalContacts ?></strong>
            <?php if ($search !== ''): ?>
                <span class="muted">(Showing <?= count($contacts) ?> matching result<?= count($contacts) === 1 ? '' : 's' ?>)</span>
            <?php endif; ?>
        </div>

        <form method="get" action="index.php" class="search-form">
            <input
                type="text"
                name="search"
                placeholder="Search by name or email..."
                value="<?= e($search) ?>"
                aria-label="Search contacts"
            >
            <button type="submit" class="btn btn-primary">Search</button>
            <?php if ($search !== ''): ?>
                <a href="index.php" class="btn btn-secondary">Reset</a>
            <?php endif; ?>
        </form>
    </div>

    <?php if (empty($contacts)): ?>
        <div class="empty-state">
            <p>No contacts found<?= $search !== '' ? ' matching "' . e($search) . '"' : '' ?>.</p>
            <a href="add.php" class="btn btn-primary">+ Add First Contact</a>
        </div>
    <?php else: ?>
        <div class="table-responsive">
            <table class="data-table">
                <thead>
                    <tr>
                        <th><?= sortLink('name', 'Name', $sortParam, $sortDir, $search) ?></th>
                        <th><?= sortLink('email', 'Email', $sortParam, $sortDir, $search) ?></th>
                        <th><?= sortLink('phone', 'Phone', $sortParam, $sortDir, $search) ?></th>
                        <th><?= sortLink('group_name', 'Group', $sortParam, $sortDir, $search) ?></th>
                        <th><?= sortLink('created_at', 'Created At', $sortParam, $sortDir, $search) ?></th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($contacts as $contact): ?>
                        <tr>
                            <td>
                                <strong><?= e($contact['name']) ?></strong>
                                <?php if (!empty($contact['notes'])): ?>
                                    <div class="note-preview"><?= e($contact['notes']) ?></div>
                                <?php endif; ?>
                            </td>
                            <td><?= e($contact['email'] ?: '—') ?></td>
                            <td><?= e($contact['phone'] ?: '—') ?></td>
                            <td><span class="badge badge-<?= strtolower(e($contact['group_name'])) ?>"><?= e($contact['group_name']) ?></span></td>
                            <td><?= e(date('Y-m-d H:i', strtotime((string) $contact['created_at']))) ?></td>
                            <td class="actions-cell">
                                <a href="edit.php?id=<?= (int) $contact['id'] ?>" class="btn btn-sm btn-edit">Edit</a>
                                <a href="delete.php?id=<?= (int) $contact['id'] ?>" class="btn btn-sm btn-delete">Delete</a>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    <?php endif; ?>
</section>

<?php renderFooter(); ?>