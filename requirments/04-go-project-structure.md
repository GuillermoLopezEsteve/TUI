# LabCheck: Go Project Structure

**Document status:** Implementation-architecture guidance
**Related documents:**

- [Overview](./00-overview.md)
- [Activities, tests and authoring](./01-activities-tests-authoring.md)
- [Runner and config](./02-runner-and-config.md)
- [UI screens and keybindings](./03-ui-screens-and-keybindings.md)

This is sensible Go project layout, not part of the earlier YAML-manifest design being
superseded — it's carried over because it's just good practice for a Bubble Tea app of this
shape.

## 1. Package layout

```text
cmd/labcheck/          program entry point
internal/app/          root Bubble Tea model, screen/tab navigation
internal/config/       reads/writes the single `config` file (student number + timeout)
internal/activity/     folder scanner: activities/sections via `meta` files, tests via
                        script comment-header parsing (no YAML)
internal/runner/       Bash execution, global timeout, pass/fail classification
internal/highlight/    3-rule Bash highlighter (keywords / quoted strings / comments)
internal/i18n/         Catalan UI strings
activitats/            instructor-authored activity directories
```

## 2. Root model state

```go
type Screen int

const (
    ScreenStudentNumber Screen = iota
    ScreenActivities
    ScreenActivity
)

type Tab int

const (
    TabList Tab = iota
    TabDetail
)

type Model struct {
    Screen        Screen
    Tab           Tab
    Modal         ModalState
    StudentNumber int
    Activities    []Activity
    Selected      Selection
    Results       map[TestKey]TestResult
    Width         int
    Height        int
    FatalError    error
}
```

## 3. Domain model

```go
type Activity struct {
    ID          string // folder name
    Title       string // from meta
    Description string // from meta
    Sections    []Section
    RootDir     string
}

type Section struct {
    ID          string
    Title       string
    Description string
    Tests       []TestCase
}

type TestCase struct {
    ID          string // derived from script filename
    Title       string // parsed from "# TITLE:"
    Description string // parsed from "# DESCRIPTION:"
    ScriptPath  string
}
```

## 4. Asynchronous messages

```go
type ActivitiesLoadedMsg struct{ Activities []Activity }
type TestStartedMsg struct{ Key TestKey }
type TestFinishedMsg struct{ Key TestKey; Result TestResult }
type SectionBatchAdvancedMsg struct{}
type ScriptLoadedMsg struct{ Path string; Content string; Err error }
type ConfigSavedMsg struct{ StudentNumber int; Err error }
```

Script execution and folder scanning must run as `tea.Cmd`s, never inline inside `Update` or
`View` — I/O belongs in commands so the UI stays responsive.

## 5. Reused libraries

- Bubble Tea v2 for the model-update-view loop: <https://github.com/charmbracelet/bubbletea>
- Lip Gloss for declarative styling/layout: <https://github.com/charmbracelet/lipgloss>
- Go's `os.UserConfigDir()` for the config file location.
- Go's `os/exec` with `exec.CommandContext` for cancellable, timeout-bound test execution.
