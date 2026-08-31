> **Superseded:** this document has been replaced by the simplified spec in
> [`requirments/`](./requirments/00-overview.md). Kept for historical reference only.

# LabCheck: Bash Test Script Contract and Runner Design
 
**Document status:** Test-authoring and execution specification  
**Related documents:**
 
- [Overall Goals and Application Requirements](./01-overall-goals-and-requirements.md)
- [Activity Model and Authoring Guide](./02-activity-model-and-authoring.md)
## 1. Purpose
 
Each LabCheck test is an instructor-authored Bash script that verifies one requirement. The Go runner executes it with a personalized student number, captures its output, enforces a hard timeout, and converts the result into a consistent status for the TUI.
 
A good test is:
 
- **Atomic:** it evaluates one requirement.
- **Exhaustive within that requirement:** it checks all relevant details needed to decide whether that requirement is satisfied.
- **Read-only whenever possible:** it observes student work rather than changing it.
- **Deterministic:** the same machine state produces the same result.
- **Actionable:** failure output states what was expected and what was observed.
## 2. Canonical test metadata
 
The test title and description live in `activity.yaml` beside the script path:
 
```yaml
- id: student-a-record
  title: Student A record uses the personalized address
  description: Checks that mail.lab.test resolves to 10.10.10.{{student_number}}.
  script: tests/dns/student-a-record.sh
  timeout_seconds: 10
```
 
The Bash file contains the executable assertion. Keeping metadata in one canonical location prevents the UI description and script comments from drifting apart.
 
Scripts should still include ordinary comments explaining non-obvious implementation details.
 
## 3. Invocation contract
 
The runner invokes Bash directly, without `sh -c`:
 
```text
/bin/bash --noprofile --norc <absolute-script-path> <student-number>
```
 
For student `42`:
 
```text
/bin/bash --noprofile --norc /usr/share/labcheck/activities/mail-server/tests/dns/student-a-record.sh 42
```
 
### 3.1 Positional parameter
 
The first positional parameter is always the validated decimal student number:
 
```bash
student_number="${1:?missing student number}"
```
 
The application guarantees a value from `1` to `254`. Scripts should still validate it defensively when used outside LabCheck.
 
### 3.2 Environment variables
 
The runner also sets:
 
| Variable | Example | Purpose |
|---|---|---|
| `LABCHECK_STUDENT_NUMBER` | `42` | Same value as `$1`; useful for sourced helpers. |
| `LABCHECK_ACTIVITY_ID` | `mail-server` | Current activity identifier. |
| `LABCHECK_TOPIC_ID` | `dns` | Current topic identifier. |
| `LABCHECK_TEST_ID` | `student-a-record` | Current test identifier. |
| `LABCHECK_ACTIVITY_DIR` | `/usr/share/labcheck/activities/mail-server` | Absolute trusted activity root. |
| `LABCHECK_TIMEOUT_SECONDS` | `10` | Effective timeout for information only. |
 
The positional argument is the primary interface. Environment variables provide context and must contain the same validated data.
 
### 3.3 Working directory and input
 
- The current working directory is the activity root.
- Standard input is connected to `/dev/null`.
- The script must not prompt for input.
- The script must not launch a pager, editor, or interactive command.
- Locale should be stable, preferably `LC_ALL=C`, unless a test explicitly needs localized output.
## 4. Result protocol
 
### 4.1 Exit codes
 
| Exit code | Runner status | Meaning |
|---:|---|---|
| `0` | Passed | The requirement is satisfied. |
| `1` | Failed | The script ran correctly, but the expected state was not found. |
| `2` | Error | The script could not perform a valid check, for example because a required command or permission is missing. |
| `126` or `127` | Error | Command could not execute or was not found. |
| Other non-zero | Error | Unexpected script failure. |
| Killed after timeout | Timed out | The runner exceeded the configured limit. |
 
A timeout is determined by the Go runner, not by a script exit code. Scripts must not use `124` to simulate a LabCheck timeout.
 
### 4.2 Human-readable reason
 
A script should print one concise final reason using this marker:
 
```text
LABCHECK_REASON=<message>
```
 
Examples:
 
```text
LABCHECK_REASON=mail.lab.test resolves to the expected address 10.10.10.42
LABCHECK_REASON=expected 10.10.10.42 but received 10.10.10.41
LABCHECK_REASON=the dig command is not installed
```
 
Recommended destinations:
 
- Passed reason: stdout.
- Failed or error reason: stderr.
The message is plain text and must stay on one line. It must not contain secrets.
 
The runner chooses the displayed reason in this order:
 
1. Last `LABCHECK_REASON=` line in stderr.
2. Last `LABCHECK_REASON=` line in stdout.
3. Last non-empty stderr line.
4. Last non-empty stdout line.
5. A generated fallback based on exit code.
The full bounded stdout and stderr remain available in the detail pane.
 
### 4.3 Optional helper functions
 
Activities may include a trusted helper file:
 
```bash
# lib/labcheck.sh
pass() {
    printf 'LABCHECK_REASON=%s\n' "$1"
    exit 0
}
 
fail() {
    printf 'LABCHECK_REASON=%s\n' "$1" >&2
    exit 1
}
 
error() {
    printf 'LABCHECK_REASON=%s\n' "$1" >&2
    exit 2
}
```
 
A test can source it through the trusted activity directory:
 
```bash
# shellcheck source=/dev/null
source "${LABCHECK_ACTIVITY_DIR}/lib/labcheck.sh"
```
 
The runner does not require the helper; ordinary `printf` and `exit` calls are valid.
 
## 5. Standard script template
 
```bash
#!/usr/bin/env bash
set -u
set -o pipefail
 
student_number="${1:-}"
 
if [[ ! "$student_number" =~ ^[0-9]+$ ]] ||
   (( student_number < 1 || student_number > 254 )); then
    printf 'LABCHECK_REASON=student number must be an integer from 1 to 254\n' >&2
    exit 2
fi
 
# Perform one atomic assertion here.
 
printf 'LABCHECK_REASON=the expected condition is satisfied\n'
exit 0
```
 
Do not use `set -e` blindly. A command returning non-zero is often the condition being tested, and immediate termination can produce a vague failure instead of an intentional reason. Authors may use `set -e` only when every expected non-zero command is handled explicitly.
 
## 6. Personalized test examples
 
### 6.1 Expected IPv4 address
 
```bash
#!/usr/bin/env bash
set -u
set -o pipefail
 
student_number="${1:-}"
expected_ip="10.10.10.${student_number}"
 
if ! command -v dig >/dev/null 2>&1; then
    printf 'LABCHECK_REASON=the dig command is not installed\n' >&2
    exit 2
fi
 
actual_ips="$(dig +short A mail.lab.test 2>/dev/null | sed '/^$/d' | sort -u)"
 
if [[ -z "$actual_ips" ]]; then
    printf 'LABCHECK_REASON=mail.lab.test returned no IPv4 address; expected %s\n' "$expected_ip" >&2
    exit 1
fi
 
if grep -Fxq "$expected_ip" <<<"$actual_ips"; then
    printf 'LABCHECK_REASON=mail.lab.test includes the expected address %s\n' "$expected_ip"
    exit 0
fi
 
printf 'LABCHECK_REASON=expected %s but received: %s\n' \
    "$expected_ip" "$(tr '\n' ' ' <<<"$actual_ips" | sed 's/[[:space:]]*$//')" >&2
exit 1
```
 
This test is atomic because it checks one DNS requirement. It is exhaustive within that requirement because it handles missing tools, no response, multiple responses, and an incorrect response.
 
### 6.2 Personalized account
 
```bash
#!/usr/bin/env bash
set -u
 
student_number="${1:-}"
expected_user="admin${student_number}"
 
if getent passwd "$expected_user" >/dev/null 2>&1; then
    printf 'LABCHECK_REASON=user %s exists\n' "$expected_user"
    exit 0
fi
 
printf 'LABCHECK_REASON=expected local user %s was not found\n' "$expected_user" >&2
exit 1
```
 
### 6.3 Configuration parameter
 
```bash
#!/usr/bin/env bash
set -u
set -o pipefail
 
student_number="${1:-}"
config_file="/etc/example/server.conf"
expected="listen_address=10.10.10.${student_number}"
 
if [[ ! -e "$config_file" ]]; then
    printf 'LABCHECK_REASON=%s does not exist\n' "$config_file" >&2
    exit 1
fi
 
if [[ ! -r "$config_file" ]]; then
    printf 'LABCHECK_REASON=%s exists but is not readable by the current user\n' "$config_file" >&2
    exit 2
fi
 
actual_lines="$(grep -Ev '^[[:space:]]*(#|$)' "$config_file" | \
    grep -E '^[[:space:]]*listen_address[[:space:]]*=' || true)"
 
if grep -Eq "^[[:space:]]*listen_address[[:space:]]*=[[:space:]]*10\\.10\\.10\\.${student_number}[[:space:]]*$" \
    <<<"$actual_lines"; then
    printf 'LABCHECK_REASON=%s contains the expected active setting %s\n' \
        "$config_file" "$expected"
    exit 0
fi
 
if [[ -z "$actual_lines" ]]; then
    printf 'LABCHECK_REASON=no active listen_address setting was found in %s; expected %s\n' \
        "$config_file" "$expected" >&2
else
    printf 'LABCHECK_REASON=expected %s but active configuration contains: %s\n' \
        "$expected" "$(tr '\n' ';' <<<"$actual_lines")" >&2
fi
exit 1
```
 
This implementation ignores blank and commented lines and reports the actual active values.
 
## 7. Common test patterns
 
### 7.1 File exists
 
Distinguish among:
 
- Does not exist: `Failed`.
- Exists but unreadable: normally `Error` because the test cannot inspect it.
- Exists and is the wrong type: `Failed` with observed type.
### 7.2 Parameter in a file
 
A robust test should:
 
1. Confirm file existence and readability.
2. Ignore comments and blank lines when appropriate.
3. Match the complete key and value, not an accidental substring.
4. Detect duplicate active definitions when duplicates are invalid.
5. Print expected and observed values.
### 7.3 systemd service state
 
```bash
if ! command -v systemctl >/dev/null 2>&1; then
    printf 'LABCHECK_REASON=systemctl is not available on this machine\n' >&2
    exit 2
fi
 
if systemctl is-active --quiet postfix.service; then
    printf 'LABCHECK_REASON=postfix.service is active\n'
    exit 0
fi
 
state="$(systemctl is-active postfix.service 2>/dev/null || true)"
printf 'LABCHECK_REASON=postfix.service is not active; current state: %s\n' \
    "${state:-unknown}" >&2
exit 1
```
 
### 7.4 Listening port
 
Prefer structured command options and exact matching. A port check should state whether it expects TCP or UDP, IPv4 or IPv6, and a particular bind address or any address.
 
### 7.5 Logs
 
A log test should specify whether it checks:
 
- File existence.
- Non-empty content.
- A matching service event.
- A recent event within a defined time window.
These are different requirements and usually deserve separate tests.
 
## 8. Atomic but exhaustive
 
The phrase means **one decision, complete evidence**.
 
Good example:
 
> Determine whether the active DNS A records include the personalized address.
 
This one test may inspect all returned addresses and explain absence, duplicates, and mismatches.
 
Bad example:
 
> Check DNS, restart the service, verify SMTP, create a user, and send a test mail.
 
That combines several requirements and may change the student's work.
 
A test should normally have one sentence of the form:
 
```text
This test passes when <one observable requirement>.
```
 
If that sentence contains several independent uses of “and,” split the test.
 
## 9. Timeout rules
 
- Every test has an effective timeout from `1` to `30` seconds.
- The default is `30` seconds.
- An activity cannot request more than `30` seconds.
- The timer covers process startup, script execution, and output collection.
- On timeout, the runner terminates the complete process group.
- A timed-out test receives status `Timed out`, regardless of partial output.
- Captured partial output may be displayed below the timeout reason.
- The next test in a batch still runs.
Generated timeout reason:
 
```text
The test exceeded its 30-second time limit and was terminated.
```
 
Tests should use bounded command options where available, for example connection or query timeouts shorter than the runner limit.
 
## 10. Go runner design
 
### 10.1 Result model
 
```go
type TestStatus int
 
const (
    StatusNotRun TestStatus = iota
    StatusRunning
    StatusPassed
    StatusFailed
    StatusError
    StatusTimedOut
)
 
type TestResult struct {
    Key        TestKey
    Status     TestStatus
    Reason     string
    Stdout     string
    Stderr     string
    ExitCode   int
    StartedAt  time.Time
    FinishedAt time.Time
    Duration   time.Duration
}
```
 
### 10.2 Execution outline
 
```go
func RunTest(ctx context.Context, tc TestCase, ids IDs, student int) TestResult {
    timeout := time.Duration(tc.TimeoutSeconds) * time.Second
    testCtx, cancel := context.WithTimeout(ctx, timeout)
    defer cancel()
 
    cmd := exec.CommandContext(
        testCtx,
        "/bin/bash",
        "--noprofile",
        "--norc",
        tc.AbsoluteScriptPath,
        strconv.Itoa(student),
    )
 
    cmd.Dir = ids.ActivityDir
    cmd.Stdin = nil
    cmd.Env = append(filteredBaseEnv(),
        "LC_ALL=C",
        "LABCHECK_STUDENT_NUMBER="+strconv.Itoa(student),
        "LABCHECK_ACTIVITY_ID="+ids.ActivityID,
        "LABCHECK_TOPIC_ID="+ids.TopicID,
        "LABCHECK_TEST_ID="+ids.TestID,
        "LABCHECK_ACTIVITY_DIR="+ids.ActivityDir,
        "LABCHECK_TIMEOUT_SECONDS="+strconv.Itoa(tc.TimeoutSeconds),
    )
 
    // On Linux, place the child in a new process group so a timeout can
    // terminate descendants as well as the direct Bash process.
    cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}
 
    // Attach bounded writers to stdout and stderr, start, wait, classify,
    // parse the reason, and return one immutable result.
}
```
 
`exec.CommandContext` connects process cancellation to a Go context. On Linux, process-group handling is additionally required so commands spawned by the script do not survive after the parent Bash process is killed.
 
### 10.3 Bounded output
 
Each stream should use a writer that:
 
- Stores up to 64 KiB by default.
- Continues accepting writes after the limit so the child does not block.
- Marks the output as truncated.
- Appends a visible note such as `[output truncated]`.
Do not use an unbounded `bytes.Buffer` for instructor scripts that may accidentally print indefinitely.
 
### 10.4 Status classification
 
After `Wait` returns:
 
1. If the deadline expired, status is `Timed out`.
2. If process startup failed, status is `Error`.
3. Exit `0` becomes `Passed`.
4. Exit `1` becomes `Failed`.
5. Exit `2` or any other non-zero exit becomes `Error`.
6. Parse the reason using the defined precedence.
7. Record elapsed duration even for failures and timeouts.
### 10.5 Bubble Tea integration
 
The runner must execute inside a `tea.Cmd`, not inside `Update` or `View`.
 
```go
func runTestCmd(spec RunSpec) tea.Cmd {
    return func() tea.Msg {
        return TestFinishedMsg{Result: runner.Run(spec)}
    }
}
```
 
For a batch, `Update` starts the next command only after receiving the previous `TestFinishedMsg`. This keeps ordering deterministic and avoids simultaneous tests changing or locking the same service resources.
 
## 11. Cancellation and process cleanup
 
On Linux:
 
1. Start Bash in a new process group.
2. When the context expires or the user quits, signal the process group.
3. Allow a brief graceful interval only if deliberately implemented.
4. Send `SIGKILL` to the group if it is still alive.
5. Call `Wait` to release process resources.
6. Restore the terminal through Bubble Tea's normal shutdown path.
The exact cancellation code must be integration-tested with a script that launches a child `sleep` process. Passing the test requires both parent and child to be gone after timeout.
 
## 12. Privileges and trusted execution
 
Bash tests can execute arbitrary local code. Therefore:
 
- Only trusted teacher or administrator activity packs may be loaded.
- Packaged activity directories should be owned by an administrator and read-only for students.
- The runner must not accept script paths directly from student input.
- The runner must not interpolate YAML values into a shell command string.
- The application must not run itself as root by default.
- `requires_root: true` means “this check needs an intentionally privileged environment,” not “silently run sudo.”
- Interactive `sudo` is forbidden because stdin is unavailable and a hidden password prompt would hang until timeout.
- When non-interactive privilege is deliberately configured, scripts must use `sudo -n` and return a clear `Error` if permission is unavailable.
## 13. Failure-message guidelines
 
A useful failure reason includes:
 
1. The expected state.
2. The observed state.
3. The resource inspected.
Good:
 
```text
Expected /etc/postfix/main.cf to contain myhostname=mail42.lab.test, but the active value is mail.lab.test.
```
 
Weak:
 
```text
Wrong configuration.
```
 
Avoid:
 
- Full passwords, private keys, tokens, or message contents.
- Huge dumps of configuration files.
- A complete repair command when the pedagogical aim is troubleshooting.
- Blaming language such as `You did this wrong`.
## 14. Script source highlighting
 
The source popup performs lightweight lexical coloring. It must preserve every character and line exactly.
 
Suggested one-pass state machine:
 
1. Track single-quoted and double-quoted string state. Render string contents and delimiters in yellow.
2. Outside strings, track nested depth for `()`, `[]`, and `{}`. Render delimiters and their enclosed text in orange.
3. Outside strings and bracketed regions, tokenize words and render known Bash keywords in green.
4. Outside strings, text from an unescaped `#` to end of line is a dim comment.
5. Render everything else normally.
Suggested keyword set:
 
```text
if then elif else fi for while until do done case esac in function select time
```
 
This deliberately does not attempt shell expansion, heredoc, arithmetic, or grammar correctness. Incorrect highlighting must never affect execution.
 
## 15. Tests for the test runner
 
The Go project should include fixtures covering:
 
| Fixture | Expected result |
|---|---|
| Script exits `0` with reason | Passed with parsed reason. |
| Script exits `1` | Failed. |
| Script exits `2` | Error. |
| Missing Bash file | Definition or execution error. |
| Script prints no reason | Fallback reason is generated. |
| Reason appears in stderr | Stderr marker takes precedence. |
| Student number `1` | Correct argument and environment. |
| Student number `254` | Correct argument and environment. |
| Script sleeps for 31 seconds | Timed out before or at configured limit. |
| Script spawns a child sleeper | Parent and child are terminated. |
| Script writes more than output limit | Process completes and output is marked truncated. |
| Context cancelled by quit | Process ends and runner returns promptly. |
| Two batch tests | Second begins only after first finishes. |
 
## 16. Test-author checklist
 
- [ ] The script checks exactly one requirement.
- [ ] It reads the student number from `$1`.
- [ ] It handles the complete range `1` to `254`.
- [ ] It does not request interactive input.
- [ ] It does not modify the student's system unless the activity explicitly requires a safe mutation test.
- [ ] Exit `0` means pass, `1` means expected-state failure, and `2` means the check could not run correctly.
- [ ] It prints one concise `LABCHECK_REASON=` line.
- [ ] A failure reason includes expected and observed state.
- [ ] Missing commands and unreadable resources become `Error`, not a misleading `Failed` result.
- [ ] It completes comfortably before its configured timeout.
- [ ] External network calls have their own short timeout.
- [ ] It does not expose secrets.
- [ ] It has been tested in passing, failing, and broken-environment states.
## 17. References
 
- Go `exec.CommandContext`: <https://pkg.go.dev/os/exec#CommandContext>
- Go context timeouts: <https://pkg.go.dev/context#WithTimeout>
- Linux process-group configuration through Go `SysProcAttr`: <https://pkg.go.dev/syscall#SysProcAttr>
- Bubble Tea command and message architecture: <https://github.com/charmbracelet/bubbletea>
