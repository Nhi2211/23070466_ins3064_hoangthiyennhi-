# INS3064 — Homework 9: Robust PHP Calculator

**Student:** [Your Full Name]
**Student ID:** [Your Student ID]
**Date:** 2026-11-15

## Demo video

[Insert the 1–2 minute demo video URL here]

## Overview

A single-file PHP calculator (`calculator.php`) that performs addition, subtraction,
multiplication, division, modulo and exponentiation. It uses a sticky POST form,
custom exceptions, server-side error logging and session-based calculation history.
PHP, HTML and CSS live in one file; there are no external libraries or assets.

## Files

| File | Purpose |
|---|---|
| `calculator.php` | Calculator UI, validation, calculation, exceptions, logging, history |
| `.htaccess` | Blocks direct HTTP access to `calculator_errors.log` (Apache) |
| `.gitignore` | Keeps the generated log file out of Git |
| `README.md` | This document and the demo video link |

`calculator_errors.log` is created automatically on the first error and is never
committed to the repository.

## Requirements coverage

| Requirement | Implementation |
|---|---|
| Sticky POST form | `$_SERVER['REQUEST_METHOD']`, values re-populated with `htmlspecialchars()` |
| Operators | `+`, `-`, `*`, `/`, `%`, `**` via an explicit whitelist |
| Custom exceptions | `DivisionByZeroException`, `InvalidOperatorException`, `InvalidInputException` |
| Non-numeric / empty input | `is_numeric()` and empty-string checks throw `InvalidInputException` |
| Invalid operator | Whitelist check throws `InvalidOperatorException` |
| Division / modulo by zero | Pre-checked before arithmetic; throws `DivisionByZeroException` |
| Overflow / undefined result | `is_infinite()` / `is_nan()` → yellow warning, logged as `RuntimeException` |
| Unexpected errors | Final `catch (Throwable $e)` logs details, shows a generic message |
| Log format | `[YYYY-MM-DD HH:MM:SS] ExceptionType: message | Input: "a op b" | IP: user_ip` |
| Log protection | `.htaccess` denies HTTP access to `calculator_errors.log` |
| Session history | `$_SESSION['history'][] = ['expression' => ..., 'result' => ..., 'timestamp' => ...]` |
| Newest first | `array_reverse()` when rendering the table |
| Clear history | POST button resets `$_SESSION['history']` to an empty array |
| Colour-coded UI | green success, red error, yellow warning |
| Formatting | division shows exactly 4 decimals; whole results show as integers |
| No stack traces | Only friendly messages are printed; details go to the log |
| No warnings/notices | `display_errors=0`, inputs validated before arithmetic |

Example log line:

```
[2026-11-15 16:30:00] DivisionByZeroException: Cannot divide by zero. | Input: "10 / 0" | IP: 127.0.0.1
```

## How to run

### Option A — XAMPP / Apache (recommended for the video)

1. Copy this folder to `C:\xampp\htdocs\ins3064-hw9`.
2. Start **Apache** in the XAMPP Control Panel.
3. Open `http://localhost/ins3064-hw9/calculator.php`.
4. Error messages append to `calculator_errors.log`; `.htaccess` blocks direct
   browser access to that file.

### Option B — PHP built-in server

```bash
cd path/to/folder
php -S localhost:8000
```

Then open `http://localhost:8000/calculator.php`. The built-in server ignores
`.htaccess`, so use Apache if you need to demonstrate the log protection.

## Manual test cases

| Input | Expected result |
|---|---|
| `10 / 4` | Green success, result `2.5000` |
| `2 ** 10` | Green success, result `1024` |
| `5.5 % 2` | Green success, result `1.5` |
| `10 / 0` | Red error: “Cannot divide by zero.” + log entry |
| `5 % 0` | Red error: “Cannot calculate modulo with a zero divisor.” + log entry |
| `abc + 5` | Red error: “First number must be a valid number.” + log entry |
| empty operand | Red error: “First number is required.” + log entry |
| operator `^` | Red error: “The selected operator is not supported.” + log entry |
| `0 ** -1` | Red error: “Zero cannot be raised to a negative power.” + log entry |
| `10 ** 400` | Yellow warning: result too large / not a real number + log entry |
| Clear History | Yellow confirmation, history table becomes empty |

## Video walkthrough checklist

- Show the form and run one successful calculation (e.g. `10 / 4`).
- Show at least two distinct error cases with friendly colour-coded messages
  (e.g. `10 / 0` and `abc + 5`), then show the log or history.
- Point out the three custom exception classes in the code.
- Show the session history table and the Clear History button.
- Scroll through `calculator.php` so the grader can see the full implementation.
