Pythia
A comand line interface made with go, to do the automatic testing.


How can I help you today?




Recents
Web vs Claude code for project development
Jul 22
Instructions
Add instructions to tailor Claude’s responses

Context
1% of project capacity used

03-test-scripts-and-runner.md
601 lines

md




01-overall-goals-and-requirements.md
474 lines

md




02-activity-model-and-authoring.md
472 lines

md



Scheduled
Set up recurring tasks for this project.

02-activity-model-and-authoring.md

> **Superseded:** this document has been replaced by the simplified spec in
> [`requirments/`](./requirments/00-overview.md). Kept for historical reference only.

# LabCheck: Activity Model and Authoring Guide
 
**Document status:** Activity-format specification  
**Related documents:**
 
- [Overall Goals and Application Requirements](./01-overall-goals-and-requirements.md)
- [Bash Test Script Contract and Runner Design](./03-test-scripts-and-runner.md)
## 1. Purpose
 
An activity definition describes a complete practical exercise without requiring changes to the Go application. It provides the hierarchy and descriptive content shown in the interface and points to the Bash file used by each test.
 
The format is designed for teachers who are comfortable editing structured text but should not need to write Go.
 
## 2. Design principles
 
1. **Human editable:** activity structure is stored in YAML.
2. **Ordered:** topics and tests appear in file order.
3. **Versioned:** every file declares a schema version.
4. **Strict:** misspelled or unknown fields are validation errors.
5. **Portable:** all script paths are relative to the activity directory.
6. **Diagnostic:** tests are ordered as a troubleshooting guide, not only as a scoring list.
7. **Independent:** a failed early test does not prevent later tests from running.
8. **Safe by default:** definitions cannot point outside their activity directory.
## 3. Directory layout
 
Each activity occupies one directory:
 
```text
activities/
└── mail-server/
    ├── activity.yaml
    └── tests/
        ├── dns/
        │   ├── config-file-exists.sh
        │   ├── student-a-record.sh
        │   └── mx-record.sh
        ├── smtp/
        │   ├── service-running.sh
        │   └── port-listening.sh
        ├── imap/
        │   ├── service-running.sh
        │   └── student-account.sh
        └── logs/
            └── mail-log-exists.sh
```
 
Rules:
 
- The manifest filename is always `activity.yaml`.
- Script directories are organizational; the YAML hierarchy is authoritative.
- Script filenames should be lowercase kebab-case and end in `.sh`.
- The activity directory may contain supporting read-only files if a test needs them.
- Symlinked test scripts should be rejected in the initial version to avoid path and trust ambiguity.
## 4. Activity discovery
 
The implementation should support one resolved activities root. A practical search order is:
 
1. Explicit command-line option such as `--activities-dir`.
2. `LABCHECK_ACTIVITIES_DIR` environment variable.
3. A packaged default such as `/usr/share/labcheck/activities`.
4. A development fallback such as `./activities`.
The application scans immediate child directories for `activity.yaml`. Recursive activity nesting is not required.
 
The resolved activities directory should be shown in startup diagnostics and the empty state.
 
## 5. YAML schema version 1
 
### 5.1 Top-level fields
 
| Field | Type | Required | Rules |
|---|---|---:|---|
| `schema_version` | integer | Yes | Must equal `1`. |
| `id` | string | Yes | Unique lowercase slug: letters, numbers, and hyphens. |
| `title` | string | Yes | Student-facing activity name. |
| `short_description` | string | Yes | One concise line for the activity list. |
| `description` | string | Yes | Longer explanation for the activity. |
| `version` | string | Yes | Quote it, for example `"1.0"`. |
| `platform` | string | Yes | Version 1 supports `linux`. |
| `objectives` | list of strings | No | Learning objectives shown in activity information. |
| `prerequisites` | list of strings | No | Required software, permissions, or earlier work. |
| `topics` | list of topics | Yes | Must contain at least one topic. |
 
### 5.2 Topic fields
 
| Field | Type | Required | Rules |
|---|---|---:|---|
| `id` | string | Yes | Unique within the activity. |
| `title` | string | Yes | Topic heading shown in the navigation pane. |
| `description` | string | Yes | Topic-level purpose and context. |
| `tests` | list of tests | Yes | Must contain at least one test. |
 
### 5.3 Test fields
 
| Field | Type | Required | Rules |
|---|---|---:|---|
| `id` | string | Yes | Unique within the topic. |
| `title` | string | Yes | Short requirement-oriented title. |
| `description` | string | Yes | Explains exactly what is checked, not how to fix it. |
| `script` | string | Yes | Relative path to a `.sh` file inside the activity directory. |
| `timeout_seconds` | integer | No | Default `30`; allowed range `1` to `30`. |
| `requires_root` | boolean | No | Default `false`; informational and validated before execution. |
| `tags` | list of strings | No | Optional author metadata for future filtering. |
 
The title and description stored in YAML are the canonical metadata for the Bash test. They are displayed by the application and should not be parsed from comments in the script.
 
## 6. Complete example
 
```yaml
schema_version: 1
id: mail-server
title: Mail server lab
short_description: DNS, SMTP, IMAP and mail-log verification.
description: |
  Configure a functional mail server for the classroom network. The checks are
  ordered to help diagnose the system from name resolution through message
  access and logging.
version: "1.0"
platform: linux
 
objectives:
  - Configure DNS records required by a mail domain.
  - Verify SMTP and IMAP services.
  - Relate service behavior to system logs.
 
prerequisites:
  - A Linux machine using systemd.
  - The dig and ss commands installed.
  - Permission to read the service configuration and relevant logs.
 
topics:
  - id: dns
    title: DNS
    description: Verify the records clients need to locate the mail server.
    tests:
      - id: config-file-exists
        title: DNS configuration file exists
        description: Checks that the expected DNS zone file is present and readable.
        script: tests/dns/config-file-exists.sh
        timeout_seconds: 5
 
      - id: student-a-record
        title: Student A record uses the personalized address
        description: >
          Resolves mail.lab.test and checks that its IPv4 address is
          10.10.10.{{student_number}}.
        script: tests/dns/student-a-record.sh
        timeout_seconds: 10
 
      - id: mx-record
        title: Domain publishes an MX record
        description: Checks that lab.test has an MX record targeting mail.lab.test.
        script: tests/dns/mx-record.sh
 
  - id: smtp
    title: SMTP
    description: Verify that the mail-transfer service is active and reachable.
    tests:
      - id: service-running
        title: SMTP service is running
        description: Checks that the configured SMTP systemd unit is active.
        script: tests/smtp/service-running.sh
        timeout_seconds: 5
 
      - id: port-listening
        title: SMTP listens on TCP port 25
        description: Checks that a process is listening for SMTP connections.
        script: tests/smtp/port-listening.sh
        timeout_seconds: 5
 
  - id: imap
    title: IMAP
    description: Verify mailbox access and the personalized student account.
    tests:
      - id: service-running
        title: IMAP service is running
        description: Checks that the configured IMAP systemd unit is active.
        script: tests/imap/service-running.sh
        timeout_seconds: 5
 
      - id: student-account
        title: Personalized mail account exists
        description: Checks that the account admin{{student_number}} exists.
        script: tests/imap/student-account.sh
        timeout_seconds: 5
 
  - id: logs
    title: Logs
    description: Verify that mail events leave diagnostic evidence.
    tests:
      - id: mail-log-exists
        title: Mail log exists and is not empty
        description: Checks that the configured mail log is present and contains entries.
        script: tests/logs/mail-log-exists.sh
        timeout_seconds: 5
```
 
## 7. Display placeholders
 
Descriptions and titles may contain the following display placeholder:
 
| Placeholder | Rendered value |
|---|---|
| `{{student_number}}` | Current validated student number. |
 
Example:
 
```yaml
description: Checks that admin{{student_number}} exists.
```
 
For student `42`, the UI displays:
 
```text
Checks that admin42 exists.
```
 
Placeholder substitution is for UI text only. It must not be used to build a shell command. Scripts receive the number through the runner contract.
 
Unknown placeholders are validation errors so authoring mistakes are visible.
 
## 8. Ordering and diagnostic behavior
 
YAML list order defines execution and display order.
 
A good topic should move from basic prerequisites to more specific behavior. For example:
 
1. Required file exists.
2. File is readable and syntactically valid.
3. Required setting is present and correct.
4. Service is enabled or active.
5. Port is listening.
6. End-to-end behavior works.
7. Expected log evidence exists.
This order makes the activity screen act as a pseudo step-by-step troubleshooting guide.
 
Tests must still remain independent. The application does not skip test 5 merely because test 2 failed. Seeing both failures can help the student understand the complete state of the machine.
 
## 9. Validation rules
 
The loader must validate an activity before it becomes runnable.
 
### 9.1 Structural validation
 
- File is valid YAML.
- Only one YAML document is present.
- Unknown fields are rejected.
- Required fields are present and non-empty.
- `schema_version` is supported.
- `platform` is supported.
- At least one topic exists.
- Every topic has at least one test.
### 9.2 Identifier validation
 
Recommended expression:
 
```text
^[a-z0-9]+(?:-[a-z0-9]+)*$
```
 
Additionally:
 
- Activity IDs are unique across the loaded activities root.
- Topic IDs are unique within one activity.
- Test IDs are unique within one topic.
- The composite key `activity/topic/test` is globally unambiguous.
### 9.3 Script validation
 
For each test:
 
1. Join the activity root and relative script path.
2. Clean and resolve the path.
3. Confirm the resolved path remains inside the activity root.
4. Reject absolute paths.
5. Reject path traversal such as `../`.
6. Confirm the target is a regular file.
7. Reject symlinks in version 1.
8. Confirm the extension is `.sh`.
9. Confirm the file is readable.
10. Do not require the executable bit because the runner explicitly invokes Bash.
### 9.4 Value validation
 
- `timeout_seconds` is from `1` to `30`.
- `version` is a string.
- Titles should be reasonably short; 80 characters is a useful warning threshold.
- Descriptions should describe one check and avoid revealing a full solution.
- `requires_root: true` should be rare and clearly justified in prerequisites.
## 10. Loader diagnostics
 
A diagnostic should include:
 
```go
type Diagnostic struct {
    Severity string // warning or error
    File     string
    Path     string // for example topics[1].tests[2].script
    Message  string
}
```
 
Example messages:
 
```text
mail-server/activity.yaml: topics[0].tests[1].timeout_seconds: must be between 1 and 30
mail-server/activity.yaml: topics[2].tests[0].script: file does not exist
mail-server/activity.yaml: topics[1].tests[0].titel: unknown field; did you mean title?
```
 
A single invalid activity should not prevent other valid activities from loading.
 
## 11. Authoring guidelines
 
### 11.1 Activity titles
 
Use a clear noun phrase:
 
- Good: `Mail server lab`
- Good: `Secure Apache virtual hosts`
- Avoid: `Activity 4`
### 11.2 Test titles
 
Describe the expected state:
 
- Good: `SMTP listens on TCP port 25`
- Good: `Student A record uses the personalized address`
- Avoid: `Check number 3`
- Avoid: `Run dig command`
### 11.3 Test descriptions
 
A description should answer:
 
- What resource or behavior is inspected?
- What personalized expectation is used?
- What boundary is intentionally not covered by this test?
It should not provide the exact repair commands unless the learning design explicitly requires them.
 
### 11.4 Topic size
 
A practical topic usually contains 3 to 10 tests. Larger groups should be divided into clearer diagnostic stages.
 
### 11.5 Root permissions
 
Prefer checks that ordinary students can run. When privileged information is necessary:
 
- Arrange classroom permissions before the lab.
- Prefer group-readable configuration or logs.
- Use non-interactive privilege checks only when deliberately configured.
- Never allow a Bash script to display an unexpected password prompt inside the TUI.
## 12. Activity-loading data model
 
```go
type Manifest struct {
    SchemaVersion    int      `yaml:"schema_version"`
    ID               string   `yaml:"id"`
    Title            string   `yaml:"title"`
    ShortDescription string   `yaml:"short_description"`
    Description      string   `yaml:"description"`
    Version          string   `yaml:"version"`
    Platform         string   `yaml:"platform"`
    Objectives       []string `yaml:"objectives"`
    Prerequisites    []string `yaml:"prerequisites"`
    Topics           []Topic  `yaml:"topics"`
}
 
type Topic struct {
    ID          string     `yaml:"id"`
    Title       string     `yaml:"title"`
    Description string     `yaml:"description"`
    Tests       []TestCase `yaml:"tests"`
}
 
type TestCase struct {
    ID             string   `yaml:"id"`
    Title          string   `yaml:"title"`
    Description    string   `yaml:"description"`
    Script         string   `yaml:"script"`
    TimeoutSeconds int      `yaml:"timeout_seconds"`
    RequiresRoot   bool     `yaml:"requires_root"`
    Tags           []string `yaml:"tags"`
}
```
 
The decoder should apply defaults after decoding and before validation:
 
```text
timeout_seconds: 0  -> 30
requires_root: absent -> false
objectives/prerequisites/tags: absent -> empty list
```
 
A maintained YAML parser such as `go.yaml.in/yaml/v4` can be used, with strict known-field decoding enabled or equivalent validation.
 
## 13. Author workflow
 
1. Copy an existing activity directory.
2. Change the activity ID, title, descriptions, and version.
3. Define topics in teaching order.
4. Add one test entry for each atomic requirement.
5. Create the corresponding Bash scripts.
6. Run a manifest validation command such as `labcheck validate activities/mail-server`.
7. Test with student numbers `1`, a typical middle value, and `254`.
8. Deliberately break each expected condition and confirm the failure reason is useful.
9. Verify the full activity completes without an individual check exceeding its timeout.
10. Package the directory as trusted, read-only classroom content.
## 14. Recommended validation command
 
Although the TUI validates on startup, a non-interactive author command is strongly recommended:
 
```text
labcheck validate ./activities
```
 
Suggested output:
 
```text
✓ mail-server 1.0: 4 topics, 8 tests
✓ secure-web 1.2: 3 topics, 11 tests
 
2 activities valid, 0 invalid
```
 
It should return a non-zero process exit code when any activity is invalid, allowing use in CI.
 
## 15. Schema evolution
 
- Version 1 readers must reject unsupported future schema versions.
- New optional fields may be added in a later schema only with documented defaults.
- Renaming or changing the meaning of a field requires a new schema version.
- The application may include migration diagnostics, but should never silently reinterpret an old file.
Potential future fields, not part of version 1:
 
- Activity dependencies.
- Weighted assessment.
- Alternative operating systems.
- Test visibility rules.
- Shared variables beyond the student number.
- Remediation hints revealed after a chosen number of attempts.
## 16. Author checklist
 
- [ ] Activity ID is unique and uses lowercase kebab-case.
- [ ] Version is quoted.
- [ ] Every topic and test has a useful title and description.
- [ ] Tests are ordered as a troubleshooting path.
- [ ] Every script path is relative and inside the activity directory.
- [ ] Every timeout is 30 seconds or less.
- [ ] `{{student_number}}` is used only in display text.
- [ ] Scripts use the runner-provided student parameter.
- [ ] Failure messages explain expected and observed state.
- [ ] The activity works for student numbers `1` and `254`.
- [ ] No script requests interactive input.
- [ ] The manifest passes strict validation.
