/* =============================================================================
 * INS3064 - Homework 10 : Contact Manager Stylesheet
 * Student Name : Hoang Thi Yen Nhi
 * Student ID   : 23070466
 * ============================================================================= */

:root {
    --bg: #f8fafc;
    --surface: #ffffff;
    --ink: #0f172a;
    --muted: #64748b;
    --border: #e2e8f0;
    --primary: #2563eb;
    --primary-hover: #1d4ed8;
    --danger: #dc2626;
    --danger-hover: #b91c1c;
    --success-bg: #dcfce7;
    --success-ink: #166534;
    --error-bg: #fee2e2;
    --error-ink: #991b1b;
    --warning-bg: #fef3c7;
    --warning-ink: #92400e;
}

* {
    box-sizing: border-box;
}

body {
    margin: 0;
    padding: 28px 16px;
    font-family: system-ui, -apple-system, "Segoe UI", Roboto, Arial, sans-serif;
    color: var(--ink);
    background-color: var(--bg);
    line-height: 1.5;
}

.container {
    max-width: 1020px;
    margin: 0 auto;
}

.topbar {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: space-between;
    gap: 16px;
    margin-bottom: 20px;
}

.topbar h1 {
    margin: 0;
    font-size: 1.75rem;
}

.topbar h1 a {
    color: var(--ink);
    text-decoration: none;
}

.subtitle {
    margin: 2px 0 0;
    font-size: 0.9rem;
    color: var(--muted);
}

.nav-actions {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
}

.card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 14px;
    padding: 24px;
    box-shadow: 0 10px 25px -18px rgba(15, 23, 42, 0.35);
}

.form-card {
    max-width: 640px;
    margin: 0 auto;
}

.form-card h2 {
    margin-top: 0;
    margin-bottom: 18px;
}

.flash {
    padding: 13px 16px;
    margin-bottom: 18px;
    border-radius: 10px;
    border-left: 5px solid;
    font-weight: 600;
}

.flash-success {
    background: var(--success-bg);
    color: var(--success-ink);
    border-color: #16a34a;
}

.flash-error {
    background: var(--error-bg);
    color: var(--error-ink);
    border-color: #dc2626;
}

.flash-warning {
    background: var(--warning-bg);
    color: var(--warning-ink);
    border-color: #f59e0b;
}

.error-list {
    margin: 8px 0 0;
    padding-left: 20px;
    font-weight: 500;
}

.toolbar {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: space-between;
    gap: 14px;
    margin-bottom: 18px;
}

.stats {
    font-size: 0.98rem;
}

.muted {
    color: var(--muted);
    font-size: 0.88rem;
}

.search-form {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;
}

.search-form input {
    min-width: 240px;
}

input[type="text"],
input[type="email"],
select,
textarea {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid #cbd5e1;
    border-radius: 8px;
    font-size: 0.96rem;
    font-family: inherit;
    color: var(--ink);
    background: #ffffff;
}

input:focus,
select:focus,
textarea:focus {
    outline: none;
    border-color: var(--primary);
    box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.16);
}

.form-group {
    margin-bottom: 16px;
}

.form-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 14px;
}

label {
    display: block;
    margin-bottom: 6px;
    font-weight: 600;
    font-size: 0.9rem;
}

.required {
    color: var(--danger);
}

.btn {
    display: inline-block;
    padding: 10px 16px;
    border: 0;
    border-radius: 8px;
    font-size: 0.94rem;
    font-weight: 600;
    text-decoration: none;
    cursor: pointer;
    transition: background-color 0.15s ease;
}

.btn-primary {
    background: var(--primary);
    color: #ffffff;
}

.btn-primary:hover {
    background: var(--primary-hover);
}

.btn-secondary {
    background: #e2e8f0;
    color: #334155;
}

.btn-secondary:hover {
    background: #cbd5e1;
}

.btn-danger {
    background: var(--danger);
    color: #ffffff;
}

.btn-danger:hover {
    background: var(--danger-hover);
}

.btn-sm {
    padding: 6px 11px;
    font-size: 0.84rem;
}

.btn-edit {
    background: #eff6ff;
    color: #1d4ed8;
    border: 1px solid #bfdbfe;
}

.btn-edit:hover {
    background: #dbeafe;
}

.btn-delete {
    background: #fef2f2;
    color: #b91c1c;
    border: 1px solid #fecaca;
}

.btn-delete:hover {
    background: #fee2e2;
}

.form-actions {
    display: flex;
    gap: 10px;
    margin-top: 10px;
}

.table-responsive {
    overflow-x: auto;
    border: 1px solid var(--border);
    border-radius: 10px;
}

.data-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 0.94rem;
}

.data-table th,
.data-table td {
    padding: 12px 14px;
    text-align: left;
    border-bottom: 1px solid var(--border);
    vertical-align: top;
}

.data-table th {
    background: #f1f5f9;
    font-size: 0.82rem;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: #475569;
    white-space: nowrap;
}

.sort-link {
    color: inherit;
    text-decoration: none;
}

.sort-link:hover {
    color: var(--primary);
}

/* Zebra striping */
.data-table tbody tr:nth-child(even) {
    background-color: #f8fafc;
}

.data-table tbody tr:hover {
    background-color: #eff6ff;
}

.note-preview {
    font-size: 0.83rem;
    color: var(--muted);
    margin-top: 3px;
}

.actions-cell {
    white-space: nowrap;
    display: flex;
    gap: 6px;
}

.badge {
    display: inline-block;
    padding: 3px 10px;
    border-radius: 999px;
    font-size: 0.8rem;
    font-weight: 600;
    background: #e2e8f0;
    color: #334155;
}

.badge-work {
    background: #dbeafe;
    color: #1e40af;
}

.badge-family {
    background: #fce7f3;
    color: #9d174d;
}

.badge-friends {
    background: #dcfce7;
    color: #166534;
}

.badge-other {
    background: #fef3c7;
    color: #92400e;
}

.confirm-warning {
    color: #b91c1c;
    font-weight: 600;
}

.detail-list {
    display: grid;
    grid-template-columns: 110px 1fr;
    gap: 10px 14px;
    padding: 16px;
    margin: 16px 0 20px;
    background: #f8fafc;
    border: 1px solid var(--border);
    border-radius: 10px;
}

.detail-list dt {
    font-weight: 700;
    color: var(--muted);
}

.detail-list dd {
    margin: 0;
}

.empty-state {
    text-align: center;
    padding: 32px 16px;
    color: var(--muted);
}

.footer {
    margin-top: 22px;
    text-align: center;
    font-size: 0.84rem;
    color: var(--muted);
}

@media (max-width: 640px) {
    .form-row {
        grid-template-columns: 1fr;
    }

    .detail-list {
        grid-template-columns: 1fr;
    }

    .search-form input {
        min-width: 100%;
    }
}