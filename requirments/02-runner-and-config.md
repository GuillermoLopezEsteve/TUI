# LabCheck: Runner and Config

**Document status:** Execution and configuration specification
**Related documents:**

- [Overview](./00-overview.md)
- [Activities, tests and authoring](./01-activities-tests-authoring.md)

## 1. Config file

A single file literally named `config`, stored in the application's user-config directory
(obtained via Go's `os.UserConfigDir()`, in an app-specific `labcheck` subfolder, e.g.
`~/.config/labcheck/config`). It holds both the persisted student number and the global
timeout:

```yaml
student_number: 42
timeout_seconds: 60
```

- Missing file → treated as first launch (ask for student number; use the default timeout).
- Writes must be atomic, and the file should be readable only by the current user where the
  OS supports it — same baseline expectation as any local credential-adjacent file.
- Changing the student number (via `U`) invalidates all in-memory results from the current
  session, since expectations tied to the old number may no longer apply.

## 2. Timeout

- One global value, `60` seconds, read from `config`. There is **no per-test override** —
  keeps both the config format and the runner simpler, per the
  [guiding principle](./00-overview.md#2-guiding-principle-keep-it-simple).
- Enforcement: the runner starts each test's Bash process in its own process group
  (`SysProcAttr{Setpgid: true}` on Linux) and ties execution to a Go `context.WithTimeout`.
  If the deadline is reached, the runner sends the signal to the whole process group (not
  just the direct child) so any subprocess the script spawned is also terminated, then waits
  to release resources.
- A timeout is treated as an ordinary failure (see [result states](#4-result-states) below)
  with a fixed message, e.g. `El test ha superat el temps límit de 60 segons.`

## 3. Execution safety baseline

Non-negotiable regardless of the metadata format:

- Never build a command by string concatenation or invoke it through `sh -c`.
- Standard input is always `/dev/null`; a script must never be able to block on a prompt.
- Script paths are resolved relative to, and confirmed to stay inside, their activity's root
  folder — no path may escape via `../` or an absolute path.
- The application does not run itself as root and does not silently elevate privileges.
- Output captured per stream should be bounded (e.g. 64 KiB) so a runaway `echo` loop in a
  student-visible instructor script can't exhaust memory; the runner keeps accepting writes
  past the limit without blocking the child, and marks the captured output as truncated.

## 4. Result states

Exactly three, deliberately simple:

| State | Symbol | Meaning |
|---|---|---|
| Not tested | `○` (empty ball) | The test has not run yet this session. |
| Passed | `✓` green | Exit code `0`. |
| Failed | `✗` red | Any non-zero exit, including a timeout. |

There is no separate "error" or "timed out" visual state — both are shown as `Failed`, with
the failure message explaining what actually happened. This intentionally drops the
finer-grained state machine from the earlier YAML-based design, in favor of a model a
student can read at a glance.

## 5. Batch execution ("run section")

Pressing `a` on a highlighted section runs every test in that section, sequentially, in
listed order:

1. Mark the first test `Running` (transiently — not a persisted state, just UI feedback
   while its command is in flight).
2. Run it to completion (pass, fail, or timeout-as-fail).
3. Store the result and move to the next test in the section.
4. Continue even after a failure, so the student sees the complete diagnostic picture for
   that section.
5. Stop when the section's tests are exhausted or the app is quitting.

A new run request while a batch is already in progress should be ignored with a visible
message rather than starting a second overlapping run — tests execute one at a time, never
in parallel.

## 6. Go runner outline

```go
type TestStatus int

const (
    StatusNotTested TestStatus = iota
    StatusPassed
    StatusFailed
)

type TestResult struct {
    Status   TestStatus
    Message  string // shown for Failed; ignored for Passed (fixed "PROVA SUPERADA" text)
    Duration time.Duration
}

func RunTest(ctx context.Context, scriptPath string, studentNumber int, timeout time.Duration) TestResult {
    testCtx, cancel := context.WithTimeout(ctx, timeout)
    defer cancel()

    cmd := exec.CommandContext(testCtx, "/bin/bash", "--noprofile", "--norc",
        scriptPath, strconv.Itoa(studentNumber))
    cmd.Dir = filepath.Dir(scriptPath) // activity root, per test's activity
    cmd.Stdin = nil
    cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}

    // capture bounded stdout/stderr, run, classify exit 0 vs non-zero vs
    // testCtx.Err() == context.DeadlineExceeded, extract the last non-empty
    // output line as Message on failure.
}
```

Must run as a `tea.Cmd`, never inline in `Update`/`View`, so the UI stays responsive while a
test (or a whole section batch) is executing.
