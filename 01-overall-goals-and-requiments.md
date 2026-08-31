> **Superseded:** this document has been replaced by the simplified spec in
> [`requirments/`](./requirments/00-overview.md). Kept for historical reference only.

# LabCheck: Overall Goals and Application Requirements
 
**Document status:** Design specification  
**Working application name:** LabCheck  
**Target platform:** Linux classroom machines  
**Implementation:** Go with Bubble Tea v2  
**Related documents:**
 
- [Activity Model and Authoring Guide](./02-activity-model-and-authoring.md)
- [Bash Test Script Contract and Runner Design](./03-test-scripts-and-runner.md)
## 1. Purpose
 
LabCheck is a terminal user interface for students completing computing and system-administration labs. It runs instructor-authored Bash checks and presents the result as a guided diagnostic checklist.
 
The application does **not** complete the activity for the student. It shows what is correct, what is missing, and why a check failed, so the student can troubleshoot their own work.
 
A student number from `1` to `254` personalizes tests. For example, student `42` may be expected to configure `10.10.10.42` or create an account named `admin42`.
 
## 2. Product goals
 
### 2.1 Student goals
 
1. See the complete structure of a lab as topics and small checks.
2. Run one check, all checks in a topic, or the complete activity.
3. Receive a precise explanation when a requirement is not satisfied.
4. Re-run checks quickly after making a correction.
5. Understand the expected configuration without exposing a full solution.
### 2.2 Teacher goals
 
1. Add or modify activities without recompiling the Go application.
2. Write checks as ordinary Bash scripts.
3. Personalize requirements with the student number.
4. Organize checks in the same order as the teaching sequence.
5. Diagnose classroom problems consistently across many computers.
### 2.3 Engineering goals
 
1. Keep the interface responsive while tests execute.
2. Prevent a hanging test from blocking the application for more than 30 seconds.
3. Produce deterministic and inspectable results.
4. Keep activity files and scripts readable enough for teachers to maintain.
5. Fail safely when an activity, script, permission, or dependency is invalid.
## 3. Non-goals
 
The first version will not:
 
- Automatically repair student configurations.
- Replace teacher assessment or calculate a final official grade.
- Execute tests on remote computers.
- Download untrusted activities from the internet.
- Provide a general-purpose terminal or script editor.
- Hide the test source from students.
- Run tests in parallel.
- Attempt to bypass Linux permissions.
## 4. Core concepts
 
| Concept | Meaning |
|---|---|
| Student number | Integer from `1` to `254`, persisted locally and injected into every test. |
| Activity | A complete practical exercise, such as configuring a mail server. |
| Topic | A logical section within an activity, such as DNS, SMTP, IMAP, or logs. |
| Test | One atomic Bash check with a title, description, script path, and result. |
| Result | `Not run`, `Running`, `Passed`, `Failed`, `Error`, or `Timed out`. |
| Batch | A sequential run of all tests in one topic or one activity. |
 
## 5. Functional requirements
 
### 5.1 Student identity
 
- **FR-ID-01:** The student number must be an integer between `1` and `254`, inclusive.
- **FR-ID-02:** On first launch, the application must open the student-number screen before showing activities.
- **FR-ID-03:** After a valid number is confirmed, it must be stored in the user configuration directory.
- **FR-ID-04:** Pressing `U` on any screen must open the student-number screen as a modal overlay.
- **FR-ID-05:** Invalid input must remain visible with a concise validation message.
- **FR-ID-06:** Changing the student number must invalidate all results from the current session, because their expectations may no longer be valid.
- **FR-ID-07:** Configuration writes must be atomic and the file should be readable only by the current user where the operating system supports permissions.
Recommended persisted file:
 
```yaml
schema_version: 1
student_number: 42
```
 
The application should obtain the base configuration directory through Go's `os.UserConfigDir` and create an application-specific `labcheck` directory.
 
### 5.2 Activity discovery
 
- **FR-ACT-01:** Activities must be loaded from editable YAML files rather than compiled into the binary.
- **FR-ACT-02:** Each activity must contain one or more topics.
- **FR-ACT-03:** Each topic must contain one or more tests.
- **FR-ACT-04:** Activity, topic, and test identifiers must be unique within their defined scope.
- **FR-ACT-05:** Invalid activity files must not crash the application.
- **FR-ACT-06:** An invalid activity should appear as unavailable with an author-facing validation summary, or be listed in a startup diagnostics panel.
- **FR-ACT-07:** Tests and topics must appear in the order declared in YAML.
- **FR-ACT-08:** Activity definitions must use a versioned schema.
The complete format is defined in [Activity Model and Authoring Guide](./02-activity-model-and-authoring.md).
 
### 5.3 Activity selection
 
- **FR-MENU-01:** When a student number already exists, the launch screen must list all valid activities.
- **FR-MENU-02:** Each row must show at least the activity title and short description.
- **FR-MENU-03:** Activities may additionally show version, progress, or last-run state.
- **FR-MENU-04:** `Enter` opens the selected activity.
- **FR-MENU-05:** Empty and error states must explain how an instructor can add or repair activities.
### 5.4 Activity detail screen
 
- **FR-UI-01:** The activity screen must have a navigation pane and a detail pane.
- **FR-UI-02:** The navigation pane must show tests grouped under topic headings.
- **FR-UI-03:** The detail pane must show the selected test's title and description.
- **FR-UI-04:** After execution, the detail pane must also show status, duration, failure reason, and captured output.
- **FR-UI-05:** The currently selected topic and test must be visually clear without relying only on color.
- **FR-UI-06:** The screen must show aggregate progress for the activity.
- **FR-UI-07:** Results must remain visible until the test is run again, the activity is reloaded, or the student number changes.
### 5.5 Running tests
 
- **FR-RUN-01:** `Enter` on a test runs only the selected test.
- **FR-RUN-02:** `T` runs all tests in the selected test's topic.
- **FR-RUN-03:** `Y` runs all tests in the current activity.
- **FR-RUN-04:** Topic and activity batches must run sequentially in displayed order.
- **FR-RUN-05:** The application must continue a batch after an ordinary test failure so students receive a complete diagnostic view.
- **FR-RUN-06:** The application must inject the current student number into every script.
- **FR-RUN-07:** No individual test may execute for more than 30 seconds.
- **FR-RUN-08:** A timed-out test must be terminated and shown as `Timed out`, not as an ordinary failure.
- **FR-RUN-09:** The interface must remain responsive while a script is running.
- **FR-RUN-10:** Re-running a test replaces its previous result.
- **FR-RUN-11:** A script execution error must be distinct from a failed assertion.
The execution protocol is defined in [Bash Test Script Contract and Runner Design](./03-test-scripts-and-runner.md).
 
### 5.6 Script viewer
 
- **FR-SRC-01:** Pressing `F` must open a read-only popup for the currently selected Bash script.
- **FR-SRC-02:** Pressing `F` again must close the popup.
- **FR-SRC-03:** The popup must support vertical scrolling; horizontal scrolling is recommended.
- **FR-SRC-04:** If the file cannot be read, the popup must show the reason rather than closing silently.
- **FR-SRC-05:** Highlighting must be deliberately simple and must never change the script text.
Highlighting precedence:
 
1. Quoted strings in yellow.
2. Regions inside `()`, `[]`, or `{}` in orange.
3. Recognized Bash keywords in green.
4. Comments in a dim neutral style.
5. All other text in the normal foreground color.
The highlighter is a display aid, not a complete Bash parser.
 
### 5.7 Navigation and quitting
 
- **FR-NAV-01:** `C` returns one level in the menu chain.
- **FR-NAV-02:** From the activity screen, `C` returns to the activity list.
- **FR-NAV-03:** In a popup, `C` closes the popup before navigating away.
- **FR-NAV-04:** `Esc` quits from any screen.
- **FR-NAV-05:** `Ctrl+C` quits from any screen.
- **FR-NAV-06:** If a script is active, quitting must cancel and terminate it before the terminal is restored.
- **FR-NAV-07:** Key matching should be case-insensitive for letter commands; the help bar displays uppercase labels for readability.
## 6. Screen design
 
### 6.1 Student-number modal
 
```text
┌──────────────────────────────────────────────────────────────┐
│ LabCheck                                      Student: unset │
│                                                              │
│                  Set student number                          │
│                                                              │
│                  Number [1–254]: 42_                         │
│                                                              │
│             Enter save   C cancel   Esc quit                 │
└──────────────────────────────────────────────────────────────┘
```
 
Rules:
 
- On first launch, cancel is disabled because a valid number is required.
- On later use through `U`, `C` closes the modal without saving.
- Saving a changed number clears all in-memory results after confirmation.
### 6.2 Activity list
 
```text
┌─────────────────────────────────────────────────────────────────────────┐
│ LabCheck                                                   Student: 42 │
├─────────────────────────────────────────────────────────────────────────┤
│ Activities                                                              │
│                                                                         │
│ > Mail server lab          DNS, SMTP, IMAP and log verification         │
│   Secure web server        TLS, virtual hosts and access control        │
│   DHCP and routing         Address allocation, forwarding and NAT       │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│ ↑/↓ move   Enter open   U student   C back   Esc/Ctrl+C quit            │
└─────────────────────────────────────────────────────────────────────────┘
```
 
### 6.3 Activity detail
 
```text
┌──────────────────────────────────────────────────────────────────────────────┐
│ Mail server lab                                      Student: 42   5/12 pass │
├───────────────────────────────┬──────────────────────────────────────────────┤
│ DNS                           │ DNS A record points to the student server     │
│   ✓ Configuration file       │                                              │
│ > ✗ Student A record         │ Verifies that mail.lab.test resolves to       │
│   ○ MX record                │ 10.10.10.42.                                  │
│                               │                                              │
│ SMTP                          │ Status: Failed                               │
│   ✓ Service running          │ Duration: 84 ms                               │
│   ○ Port 25 listening        │                                              │
│                               │ Why it failed                                │
│ IMAP                          │ Expected 10.10.10.42, received 10.10.10.41.   │
│   ○ Service running          │                                              │
│   ○ Login check              │ Output                                       │
│                               │ dig +short mail.lab.test                      │
├───────────────────────────────┴──────────────────────────────────────────────┤
│ Enter run test   T run topic   Y run activity   F source   U student   C back │
└──────────────────────────────────────────────────────────────────────────────┘
```
 
Status symbols:
 
| Symbol | Status |
|---|---|
| `○` | Not run |
| `⟳` | Running |
| `✓` | Passed |
| `✗` | Failed |
| `!` | Execution or definition error |
| `⏱` | Timed out |
 
### 6.4 Script popup
 
```text
┌──────────────────────── Test source ──────────────────────────┐
│ tests/dns/student-a-record.sh                                 │
│                                                              │
│ #!/usr/bin/env bash                                          │
│ set -u                                                       │
│ student_number="${1:?missing student number}"                │
│ expected_ip="10.10.10.${student_number}"                     │
│ ...                                                          │
│                                                              │
│ ↑/↓ scroll   ←/→ horizontal   F/C close                       │
└──────────────────────────────────────────────────────────────┘
```
 
### 6.5 Responsive behavior
 
- At widths of approximately 100 columns or more, use the two-pane layout.
- At smaller widths, stack the detail pane below the navigation pane.
- At very small sizes, display a minimum-size warning while preserving quit controls.
- Long titles and reasons should wrap; identifiers and paths may truncate with an ellipsis.
## 7. Visual language
 
Use Lip Gloss for declarative layout and styling.
 
### 7.1 Semantic styles
 
| Purpose | Suggested treatment |
|---|---|
| Application title | Bold |
| Selected row | Bold plus marker such as `>` |
| Passed | Green plus `✓` |
| Failed | Red plus `✗` |
| Error | Magenta or bright red plus `!` |
| Timed out | Yellow plus `⏱` |
| Running | Cyan plus `⟳` |
| Secondary text | Dim neutral |
| Bash keywords | Green |
| Quoted strings | Yellow |
| Bracketed regions | Orange, ANSI 208 where supported |
 
Color must reinforce symbols and labels, never replace them.
 
### 7.2 Help bar
 
Every screen must have a compact contextual help bar. Only actions valid on the current screen should be displayed.
 
## 8. Application architecture
 
Bubble Tea uses a model-update-view architecture. LabCheck should use one root model and explicit screen/modal state rather than launching nested terminal programs.
 
Recommended packages:
 
```text
cmd/labcheck/          program entry point
internal/app/          root Bubble Tea model and navigation
internal/config/       student-number persistence
internal/activity/     YAML loading, validation and domain models
internal/runner/       Bash execution, timeout and result parsing
internal/highlight/    simple Bash source highlighter
internal/ui/           styles and reusable view components
activities/            instructor-authored activity directories
```
 
### 8.1 Root model state
 
```go
type Screen int
 
const (
    ScreenStudentNumber Screen = iota
    ScreenActivities
    ScreenActivity
)
 
type Model struct {
    Screen        Screen
    Modal         ModalState
    StudentNumber int
    Activities    []Activity
    Selected      Selection
    Results       map[TestKey]TestResult
    Batch         BatchState
    Width         int
    Height        int
    FatalError    error
}
```
 
### 8.2 Domain model
 
```go
type Activity struct {
    ID               string
    Title            string
    ShortDescription string
    Description      string
    Version          string
    Topics           []Topic
    RootDir          string
}
 
type Topic struct {
    ID          string
    Title       string
    Description string
    Tests       []TestCase
}
 
type TestCase struct {
    ID             string
    Title          string
    Description    string
    ScriptPath     string
    TimeoutSeconds int
    RequiresRoot   bool
}
```
 
### 8.3 Asynchronous messages
 
Recommended custom messages:
 
```go
type ActivitiesLoadedMsg struct { Activities []Activity; Diagnostics []Diagnostic }
type TestStartedMsg struct { Key TestKey; StartedAt time.Time }
type TestFinishedMsg struct { Result TestResult }
type BatchAdvancedMsg struct{}
type ScriptLoadedMsg struct { Path string; Content string; Err error }
type ConfigSavedMsg struct { StudentNumber int; Err error }
```
 
Script execution must be returned as a Bubble Tea command. The `Update` method changes state when a result message arrives; the `View` method only renders current state.
 
## 9. Batch behavior
 
1. Build an ordered queue of test keys.
2. Mark the first test as `Running`.
3. Start exactly one runner command.
4. Receive `TestFinishedMsg`.
5. Store the result and advance to the next test.
6. Continue after `Failed`, `Error`, and `Timed out` results.
7. End when the queue is empty or the application is quitting.
A new run command while a batch is active should be ignored with a visible message such as `A test run is already in progress`.
 
## 10. Error handling
 
| Condition | Required behavior |
|---|---|
| Missing configuration file | Treat as first launch. |
| Corrupt configuration | Show recoverable error and ask for a new student number. |
| No activities found | Show an empty-state explanation and searched path. |
| Invalid activity YAML | Keep application usable; show validation diagnostics. |
| Missing script | Mark test as definition error. |
| Script not readable | Mark test as execution error. |
| Permission denied | Show the exact permission problem and remediation hint. |
| Missing external command | Show script error output; do not convert it into a pass/fail assertion. |
| Timeout | Kill the process group and record `Timed out`. |
| Terminal resize | Recalculate pane dimensions without losing selection or results. |
 
## 11. Non-functional requirements
 
### 11.1 Reliability
 
- A malformed activity or failing script must not crash the TUI.
- Terminal state must be restored on normal quit, `Esc`, `Ctrl+C`, and execution errors.
- Results must include a timestamp and elapsed duration.
- Output captured per stream should be bounded; 64 KiB for stdout and 64 KiB for stderr is a suitable default.
### 11.2 Security
 
- Activity scripts are executable code and must be treated as trusted instructor content.
- Script paths must be resolved relative to the activity root and must not escape it.
- The runner must not construct a command through string concatenation or `sh -c`.
- Student input must be validated as an integer before it reaches a script.
- Standard input must be disconnected so tests cannot wait for interactive answers.
- The application must not silently elevate privileges.
### 11.3 Accessibility
 
- Every status must include text or a symbol in addition to color.
- Focus and selection must remain visible in monochrome terminals.
- Help text must be available on every screen.
- Long explanations must wrap and be scrollable.
### 11.4 Maintainability
 
- The YAML schema must be versioned.
- YAML decoding should reject unknown fields to catch spelling mistakes.
- Runner, loader, config, highlighter, and navigation logic should be independently unit tested.
- Dependencies must be pinned in `go.mod`.
### 11.5 Performance
 
- Launch should not execute any test.
- Activity parsing should complete before the activity list is presented or report progress for unusually large repositories.
- UI rendering must not read files or run commands directly; I/O belongs in Bubble Tea commands.
## 12. Acceptance criteria
 
The first release is acceptable when all of the following are true:
 
1. A new user cannot reach the activity list without entering a number from `1` to `254`.
2. The number persists across launches and can be changed with `U` from every screen.
3. At least two YAML-defined activities can be added without changing Go source code.
4. An activity displays topics and tests in a left pane and test details/results in a right pane.
5. `Enter`, `T`, and `Y` run a test, topic, and activity respectively.
6. A failed test displays an actionable reason.
7. A script exceeding 30 seconds is terminated and displayed as timed out.
8. A batch continues after a failed or timed-out test.
9. `F` shows the selected script with the required simple highlighting.
10. `C` navigates back, while `Esc` and `Ctrl+C` quit and restore the terminal.
11. Changing student number clears stale results.
12. Invalid YAML and missing scripts are reported without crashing.
## 13. Suggested implementation phases
 
1. **Foundation:** root Bubble Tea model, configuration, activity list, navigation, and responsive layout.
2. **Activity model:** strict YAML loader, validation, diagnostics, and sample mail-server activity.
3. **Runner:** one-test execution, output contract, student parameter, timeout, process-group cancellation, and result rendering.
4. **Batch execution:** topic and activity queues with progress.
5. **Source viewer:** popup, scrolling, and lightweight highlighting.
6. **Hardening:** output limits, permission errors, malformed files, terminal resize, automated tests, and packaging.
## 14. References
 
- Bubble Tea repository and architecture examples: <https://github.com/charmbracelet/bubbletea>
- Bubbles reusable TUI components: <https://github.com/charmbracelet/bubbles>
- Lip Gloss terminal styling and layout: <https://github.com/charmbracelet/lipgloss>
- Go user configuration directory: <https://pkg.go.dev/os#UserConfigDir>
- Go command execution with context cancellation: <https://pkg.go.dev/os/exec#CommandContext>
