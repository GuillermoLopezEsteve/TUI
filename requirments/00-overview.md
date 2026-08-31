# LabCheck: Overview

**Document status:** Design specification (supersedes the older YAML-manifest design in the
parent folder — see the notice at the top of those files).
**Working application name:** LabCheck (placeholder, easy to rename)
**Target platform:** Linux classroom machines
**Implementation:** Go with Bubble Tea v2
**Related documents:**

- [Activities, tests and authoring](./01-activities-tests-authoring.md)
- [Runner and config](./02-runner-and-config.md)
- [UI screens and keybindings](./03-ui-screens-and-keybindings.md)
- [Go project structure](./04-go-project-structure.md)

## 1. Purpose

LabCheck is a terminal user interface for students completing computing and
system-administration labs: installing, configuring and managing services such as DHCP, DNS,
a mail server, a file-transfer/FTP server, remote management, proxies, wifi, and similar —
the list of activities is open-ended, not fixed to these examples.

The application does **not** configure anything for the student. It runs instructor-authored
Bash checks and reports, per check, what is correct and what is not — guiding the student
toward fixing their own work rather than grading it exhaustively.

## 2. Guiding principle: keep it simple

Every test must be **atomic and deliberately simple** — one observable fact per test (a file
exists, a permission is correct, an IP is correct, a service is running, there is internet
connectivity, and so on). Do not write a test that checks many things at once; split it
instead. This principle drives several later decisions (no YAML manifest, single global
timeout, three-state result model, three-rule syntax highlighting).

## 3. Core concepts

| Concept | Meaning |
|---|---|
| Student number | Integer from `1` to `100`, persisted locally and injected into every test. |
| Activity | A complete lab, e.g. "DHCP", "DNS", "Mail server", "FTP server". |
| Section | A group of related tests within an activity (was called "Topic" in the earlier design). |
| Test | One atomic Bash check: a title, a description, and pass/fail behavior, all defined in one `.sh` file. |
| Result | `Not tested`, `Passed`, or `Failed` — a deliberately simple 3-state model. |

## 4. Student identity and personalization

- Range: integer `1`–`100`, inclusive.
- On first launch, the app must ask for the student number before showing any activity.
- Pressing `U` on any screen reopens the student-number screen to change it.
- The number is injected into every test script (see
  [Activities, tests and authoring](./01-activities-tests-authoring.md)) so checks can be
  personalized per student. Examples used consistently across activities:

| Personalized item | Pattern | Example for student `50` |
|---|---|---|
| Admin username | `admin{N}` | `admin50` |
| Test file name | `test-file-{N}` | `test-file-50` |
| IP address | `192.168.10.{N}` | `192.168.10.50` |

Activity authors should follow the same `{N}` substitution pattern for any other
per-student resource they introduce, so students can quickly tell which value is "theirs."

## 5. Language requirement

**All application-facing UI text must be in Catalan.** This includes screen titles, labels,
help bars, status text, and validation messages. Example key strings (English → Catalan) to
anchor the i18n work — the full string table lives in `internal/i18n`
(see [Go project structure](./04-go-project-structure.md)):

| English (reference only) | Catalan |
|---|---|
| Set student number | Introdueix el número d'estudiant |
| Activities | Activitats |
| TEST PASSED | PROVA SUPERADA |
| U student  Enter run  a run section  t view script | U estudiant  Enter executar  a executar secció  t veure script |

Everything else (source code, comments, these spec documents) stays in English, matching the
rest of the codebase — only the strings actually shown to the student need translating.

## 6. Non-goals

- Automatically repairing student configurations.
- Replacing teacher assessment or calculating an official grade.
- Testing remote computers.
- Distinguishing "error" from "failure" in the UI — kept as a single `Failed` state (see
  [Runner and config](./02-runner-and-config.md)).
- Running tests in parallel.
- Bypassing Linux permissions.
