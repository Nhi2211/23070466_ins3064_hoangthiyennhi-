<?php
/**
 * INS3064 - Homework 9 : Robust PHP Calculator
 * Student    : [Your Full Name]
 * Student ID : [Your Student ID]
 * Date       : 2026-11-15
 *
 * Single-file PHP calculator with:
 *   - sticky POST form and operator whitelist
 *   - three custom exception classes plus overflow handling
 *   - per-error logging to calculator_errors.log (protected by .htaccess)
 *   - session-based calculation history (newest first)
 *   - colour-coded, friendly messages (no stack traces)
 */

declare(strict_types=1);

date_default_timezone_set('Asia/Ho_Chi_Minh');
ini_set('display_errors', '0');
error_reporting(E_ALL);

session_start();

const OPERATORS = ['+', '-', '*', '/', '%', '**'];
define('ERROR_LOG_FILE', __DIR__ . '/calculator_errors.log');

/**
 * Thrown when the divisor is zero (division or modulo).
 */
class DivisionByZeroException extends Exception
{
}

/**
 * Thrown when the submitted operator is not in the whitelist.
 */
class InvalidOperatorException extends Exception
{
}

/**
 * Thrown when an operand is missing, non-numeric or out of range.
 */
class InvalidInputException extends Exception
{
}

function escapeHtml(string $value): string
{
    return htmlspecialchars($value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

/**
 * Reads a scalar POST field, rejects arrays, and trims it.
 */
function postString(string $key): string
{
    if (!isset($_POST[$key]) || !is_string($_POST[$key])) {
        return '';
    }
    return trim($_POST[$key]);
}

function validateOperator(string $operator): void
{
    if (!in_array($operator, OPERATORS, true)) {
        throw new InvalidOperatorException('The selected operator is not supported.');
    }
}

function parseOperand(string $raw, string $label): float
{
    if ($raw === '') {
        throw new InvalidInputException($label . ' is required.');
    }
    if (!is_numeric($raw)) {
        throw new InvalidInputException($label . ' must be a valid number.');
    }

    $value = (float) $raw;
    if (is_infinite($value) || is_nan($value)) {
        throw new InvalidInputException($label . ' is outside the supported range.');
    }

    return $value;
}

/**
 * Performs the selected operation. Division and modulo by zero are rejected
 * before the arithmetic so PHP never emits a warning.
 */
function calculate(float $a, float $b, string $operator): float
{
    switch ($operator) {
        case '+':
            return $a + $b;
        case '-':
            return $a - $b;
        case '*':
            return $a * $b;
        case '/':
            if ($b == 0.0) {
                throw new DivisionByZeroException('Cannot divide by zero.');
            }
            return $a / $b;
        case '%':
            if ($b == 0.0) {
                throw new DivisionByZeroException('Cannot calculate modulo with a zero divisor.');
            }
            // fmod keeps decimal operands exact instead of PHP's float-to-int cast.
            return fmod($a, $b);
        case '**':
            if ($a == 0.0 && $b < 0) {
                throw new DivisionByZeroException('Zero cannot be raised to a negative power.');
            }
            return $a ** $b;
        default:
            throw new InvalidOperatorException('The selected operator is not supported.');
    }
}

/**
 * Division always shows four decimals; other operations show integers when
 * the result is whole, otherwise up to four trimmed decimals.
 */
function formatResult(float $value, string $operator): string
{
    if ($operator === '/') {
        return number_format($value, 4, '.', '');
    }
    if ($value == 0.0) {
        return '0';
    }
    if (floor($value) === $value) {
        return sprintf('%.0f', $value);
    }

    return rtrim(rtrim(number_format($value, 4, '.', ''), '0'), '.');
}

/**
 * Appends one line in the required format:
 * [YYYY-MM-DD HH:MM:SS] ExceptionType: message | Input: "a op b" | IP: user_ip
 * Newlines and double quotes are neutralised to keep one error per line.
 */
function writeErrorLog(Throwable $error, string $expression): void
{
    $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    if (filter_var($ip, FILTER_VALIDATE_IP) === false) {
        $ip = 'unknown';
    }

    $message = preg_replace('/[\r\n]+/', ' ', $error->getMessage()) ?? 'Unknown error';
    $safeExpression = preg_replace('/[\r\n]+/', ' ', $expression) ?? '';
    $safeExpression = str_replace('"', "'", $safeExpression);
    if (strlen($safeExpression) > 200) {
        $safeExpression = substr($safeExpression, 0, 200) . '...';
    }

    $line = sprintf(
        "[%s] %s: %s | Input: \"%s\" | IP: %s\n",
        date('Y-m-d H:i:s'),
        get_class($error),
        $message,
        $safeExpression,
        $ip
    );

    // Logging must never break the page, so a failed write is ignored.
    @file_put_contents(ERROR_LOG_FILE, $line, FILE_APPEND | LOCK_EX);
}

$operatorLabels = [
    '+'  => '+ (add)',
    '-'  => '- (subtract)',
    '*'  => '* (multiply)',
    '/'  => '/ (divide)',
    '%'  => '% (modulo)',
    '**' => '** (power)',
];

$num1Input = '';
$num2Input = '';
$selectedOperator = '+';
$message = null;
$lastExpression = '';
$lastResult = '';

if (($_SERVER['REQUEST_METHOD'] ?? '') === 'POST') {
    if (isset($_POST['clear_history'])) {
        $_SESSION['history'] = [];
        $message = [
            'type' => 'warning',
            'text' => 'Calculation history has been cleared.',
        ];
    } else {
        $num1Input = postString('num1');
        $num2Input = postString('num2');
        $operatorInput = postString('operator');

        if (in_array($operatorInput, OPERATORS, true)) {
            $selectedOperator = $operatorInput;
        }

        $expressionForLog = $num1Input . ' ' . $operatorInput . ' ' . $num2Input;

        try {
            validateOperator($operatorInput);
            $a = parseOperand($num1Input, 'First number');
            $b = parseOperand($num2Input, 'Second number');

            $result = calculate($a, $b, $operatorInput);

            if (is_infinite($result) || is_nan($result)) {
                throw new RuntimeException(
                    'Warning: the result is too large or is not a real number, so it was not saved.'
                );
            }

            $formattedResult = formatResult($result, $operatorInput);
            $lastExpression = $num1Input . ' ' . $operatorInput . ' ' . $num2Input;
            $lastResult = $formattedResult;

            if (!isset($_SESSION['history']) || !is_array($_SESSION['history'])) {
                $_SESSION['history'] = [];
            }
            $_SESSION['history'][] = [
                'expression' => $lastExpression,
                'result' => $formattedResult,
                'timestamp' => date('Y-m-d H:i:s'),
            ];

            $message = [
                'type' => 'success',
                'text' => 'Calculation completed successfully.',
            ];
        } catch (DivisionByZeroException | InvalidOperatorException | InvalidInputException $e) {
            writeErrorLog($e, $expressionForLog);
            $message = [
                'type' => 'error',
                'text' => $e->getMessage(),
            ];
        } catch (RuntimeException $e) {
            writeErrorLog($e, $expressionForLog);
            $message = [
                'type' => 'warning',
                'text' => $e->getMessage(),
            ];
        } catch (Throwable $e) {
            // Unexpected failure: log the details, show only a safe message.
            writeErrorLog($e, $expressionForLog);
            $message = [
                'type' => 'error',
                'text' => 'An unexpected error occurred. Please try again.',
            ];
        }
    }
}

$history = $_SESSION['history'] ?? [];
if (!is_array($history)) {
    $history = [];
}
$historyNewestFirst = array_reverse($history);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Online Calculator &middot; INS3064</title>
    <style>
        :root {
            --ink: #0f172a;
            --muted: #64748b;
            --line: #e2e8f0;
            --primary: #2563eb;
            --primary-dark: #1d4ed8;
            --green-bg: #dcfce7;
            --green-ink: #166534;
            --red-bg: #fee2e2;
            --red-ink: #991b1b;
            --yellow-bg: #fef3c7;
            --yellow-ink: #92400e;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            min-height: 100vh;
            padding: 32px 16px;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            font-family: system-ui, -apple-system, "Segoe UI", Roboto, Arial, sans-serif;
            color: var(--ink);
            background: linear-gradient(135deg, #eff6ff 0%, #f8fafc 55%, #eef2ff 100%);
        }

        .app {
            width: min(780px, 100%);
        }

        .app-header {
            margin-bottom: 18px;
            text-align: center;
        }

        .app-header h1 {
            margin: 0 0 6px;
            font-size: clamp(1.6rem, 3vw, 2.1rem);
            letter-spacing: -0.02em;
        }

        .app-header p {
            margin: 0;
            color: var(--muted);
            font-size: 0.95rem;
        }

        .card {
            background: #ffffff;
            border: 1px solid var(--line);
            border-radius: 16px;
            padding: 24px;
            box-shadow: 0 18px 40px -24px rgba(15, 23, 42, 0.35);
        }

        .grid {
            display: grid;
            grid-template-columns: 1fr 150px 1fr;
            gap: 14px;
            align-items: end;
        }

        .field label {
            display: block;
            margin-bottom: 6px;
            font-size: 0.85rem;
            font-weight: 700;
            letter-spacing: 0.04em;
            text-transform: uppercase;
            color: var(--muted);
        }

        input,
        select {
            width: 100%;
            padding: 12px 14px;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            background: #f8fafc;
            font-size: 1rem;
            color: var(--ink);
            transition: border-color 0.15s ease, box-shadow 0.15s ease;
        }

        input:focus,
        select:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.18);
            background: #ffffff;
        }

        .actions {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 18px;
        }

        button {
            border: 0;
            border-radius: 10px;
            padding: 12px 20px;
            font-size: 0.98rem;
            font-weight: 700;
            cursor: pointer;
            transition: transform 0.05s ease, background 0.15s ease;
        }

        button:active {
            transform: translateY(1px);
        }

        .primary {
            background: var(--primary);
            color: #ffffff;
        }

        .primary:hover {
            background: var(--primary-dark);
        }

        .secondary {
            background: #e2e8f0;
            color: #334155;
        }

        .secondary:hover {
            background: #cbd5e1;
        }

        .message {
            margin-top: 18px;
            padding: 13px 16px;
            border-left: 5px solid;
            border-radius: 10px;
            font-weight: 650;
            line-height: 1.45;
            overflow-wrap: anywhere;
        }

        .message.success {
            background: var(--green-bg);
            color: var(--green-ink);
            border-color: #16a34a;
        }

        .message.error {
            background: var(--red-bg);
            color: var(--red-ink);
            border-color: #dc2626;
        }

        .message.warning {
            background: var(--yellow-bg);
            color: var(--yellow-ink);
            border-color: #f59e0b;
        }

        .result {
            margin-top: 18px;
            padding: 20px;
            text-align: center;
            border: 1px solid #bfdbfe;
            border-radius: 12px;
            background: #eff6ff;
        }

        .result .expression {
            color: #1e3a8a;
            font-size: 1.1rem;
            font-weight: 650;
            overflow-wrap: anywhere;
        }

        .result .equals {
            margin: 6px 0 2px;
            color: #60a5fa;
            font-size: 0.85rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.18em;
        }

        .result .value {
            color: #1e40af;
            font-size: clamp(1.7rem, 4vw, 2.3rem);
            font-weight: 800;
            overflow-wrap: anywhere;
        }

        .history {
            margin-top: 22px;
        }

        .history-head {
            display: flex;
            align-items: baseline;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 14px;
        }

        .history-head h2 {
            margin: 0;
            font-size: 1.15rem;
        }

        .history-head span {
            color: var(--muted);
            font-size: 0.85rem;
        }

        .history-wrap {
            overflow-x: auto;
            border: 1px solid var(--line);
            border-radius: 12px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.94rem;
        }

        th,
        td {
            padding: 11px 14px;
            text-align: left;
            border-bottom: 1px solid var(--line);
            white-space: nowrap;
        }

        th {
            background: #f8fafc;
            color: var(--muted);
            font-size: 0.78rem;
            letter-spacing: 0.06em;
            text-transform: uppercase;
        }

        tbody tr:last-child td {
            border-bottom: 0;
        }

        tbody tr:hover {
            background: #f8fafc;
        }

        td:nth-child(2),
        td:nth-child(3) {
            font-variant-numeric: tabular-nums;
            font-weight: 600;
        }

        .empty {
            margin: 0;
            padding: 10px 2px;
            color: var(--muted);
        }

        .footer {
            margin: 16px 0 0;
            text-align: center;
            color: var(--muted);
            font-size: 0.82rem;
        }

        @media (max-width: 620px) {
            body {
                padding: 18px 12px;
            }

            .card {
                padding: 18px;
            }

            .grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
<main class="app">
    <header class="app-header">
        <h1>Online Calculator</h1>
        <p>INS3064 &middot; Homework 9 &mdash; exceptions, logging and session history</p>
    </header>

    <section class="card" aria-label="Calculator">
        <form method="post" action="">
            <div class="grid">
                <div class="field">
                    <label for="num1">First number</label>
                    <input
                        type="text"
                        id="num1"
                        name="num1"
                        inputmode="decimal"
                        autocomplete="off"
                        placeholder="e.g. 12.5"
                        value="<?= escapeHtml($num1Input) ?>"
                    >
                </div>

                <div class="field">
                    <label for="operator">Operator</label>
                    <select id="operator" name="operator">
                        <?php foreach ($operatorLabels as $operatorValue => $operatorLabel): ?>
                            <option
                                value="<?= escapeHtml($operatorValue) ?>"
                                <?= $selectedOperator === $operatorValue ? 'selected' : '' ?>
                            ><?= escapeHtml($operatorLabel) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>

                <div class="field">
                    <label for="num2">Second number</label>
                    <input
                        type="text"
                        id="num2"
                        name="num2"
                        inputmode="decimal"
                        autocomplete="off"
                        placeholder="e.g. 4"
                        value="<?= escapeHtml($num2Input) ?>"
                    >
                </div>
            </div>

            <div class="actions">
                <button type="submit" class="primary">Calculate</button>
                <button type="submit" class="secondary" name="clear_history" value="1" formnovalidate>
                    Clear History
                </button>
            </div>
        </form>

        <?php if ($message !== null): ?>
            <div class="message <?= escapeHtml($message['type']) ?>" role="status" aria-live="polite">
                <?= escapeHtml($message['text']) ?>
            </div>
        <?php endif; ?>

        <?php if ($lastExpression !== ''): ?>
            <div class="result" aria-live="polite">
                <div class="expression"><?= escapeHtml($lastExpression) ?></div>
                <div class="equals">equals</div>
                <div class="value"><?= escapeHtml($lastResult) ?></div>
            </div>
        <?php endif; ?>
    </section>

    <section class="card history" aria-label="Calculation history">
        <div class="history-head">
            <h2>Calculation History</h2>
            <span><?= count($history) ?> record<?= count($history) === 1 ? '' : 's' ?></span>
        </div>

        <?php if ($historyNewestFirst === []): ?>
            <p class="empty">No calculations yet. Submit the form above to create history.</p>
        <?php else: ?>
            <div class="history-wrap">
                <table>
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Expression</th>
                            <th>Result</th>
                            <th>Timestamp</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($historyNewestFirst as $index => $entry): ?>
                            <tr>
                                <td><?= $index + 1 ?></td>
                                <td><?= escapeHtml((string) ($entry['expression'] ?? '')) ?></td>
                                <td><?= escapeHtml((string) ($entry['result'] ?? '')) ?></td>
                                <td><?= escapeHtml((string) ($entry['timestamp'] ?? '')) ?></td>
                            </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        <?php endif; ?>
    </section>

    <p class="footer">
        Errors are written to a protected server-side log. Raw error details and stack traces are never shown.
    </p>
</main>
</body>
</html>
