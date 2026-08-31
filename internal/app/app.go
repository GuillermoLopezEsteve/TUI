// Package app implements LabCheck's root Bubble Tea model: navigation
// between the student-number modal, the activities list, and the
// split-screen activity screen, plus test execution.
package app

import (
	"fmt"
	"os"
	"strconv"
	"strings"
	"time"

	tea "charm.land/bubbletea/v2"

	"labcheck/internal/activity"
	"labcheck/internal/config"
	"labcheck/internal/i18n"
	"labcheck/internal/runner"
)

type screen int

const (
	screenActivities screen = iota
	screenActivity
)

// testKey identifies one test within the loaded activities.
type testKey struct {
	activity int
	section  int
	test     int
}

// rowRef is one selectable row in the flattened section/test tree.
type rowRef struct {
	section int
	test    int
}

type testFinishedMsg struct {
	key    testKey
	result runner.Result
}

// Model is LabCheck's root Bubble Tea model.
type Model struct {
	cfg           config.Config
	activitiesDir string
	activitiesErr error
	activities    []activity.Activity

	screen       screen
	studentModal bool
	firstLaunch  bool
	numberInput  string
	inputErr     string

	activeActivity int
	selected       int

	results map[testKey]runner.Result

	running     bool
	runningKey  testKey
	batchActive bool
	batchQueue  []testKey
	batchIdx    int

	scriptPopup   bool
	scriptContent string
	scriptScroll  int

	width, height int
}

// New loads the config and scans the activities directory. Loading problems
// are kept on the model (activitiesErr) rather than aborting startup, so the
// TUI can still show an explanation instead of crashing.
func New() Model {
	cfg, _ := config.Load()

	dir, dirErr := activity.FindRoot()
	var acts []activity.Activity
	loadErr := dirErr
	if dirErr == nil {
		acts, loadErr = activity.Load(dir)
	}

	m := Model{
		cfg:           cfg,
		activitiesDir: dir,
		activitiesErr: loadErr,
		activities:    acts,
		results:       make(map[testKey]runner.Result),
	}

	if cfg.StudentNumber == 0 {
		m.studentModal = true
		m.firstLaunch = true
	}

	return m
}

func (m Model) Init() tea.Cmd {
	return nil
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		return m, nil
	case tea.KeyPressMsg:
		return m.handleKey(msg)
	case testFinishedMsg:
		return m.handleTestFinished(msg)
	}
	return m, nil
}

func (m Model) handleKey(msg tea.KeyPressMsg) (tea.Model, tea.Cmd) {
	key := strings.ToLower(msg.String())

	if key == "ctrl+c" {
		return m, tea.Quit
	}

	if m.studentModal {
		return m.handleStudentModalKey(key, msg)
	}
	if m.scriptPopup {
		return m.handleScriptPopupKey(key)
	}

	switch m.screen {
	case screenActivities:
		return m.handleActivitiesKey(key)
	default:
		return m.handleActivityKey(key)
	}
}

func (m Model) handleStudentModalKey(key string, msg tea.KeyPressMsg) (tea.Model, tea.Cmd) {
	switch key {
	case "esc":
		return m, tea.Quit
	case "enter":
		n, err := strconv.Atoi(m.numberInput)
		if err != nil || n < 1 || n > 100 {
			m.inputErr = i18n.InvalidNumber
			return m, nil
		}
		m.cfg.StudentNumber = n
		_ = config.Save(m.cfg)
		m.results = make(map[testKey]runner.Result)
		m.studentModal = false
		m.firstLaunch = false
		m.inputErr = ""
		m.numberInput = ""
		return m, nil
	case "backspace":
		if len(m.numberInput) > 0 {
			m.numberInput = m.numberInput[:len(m.numberInput)-1]
		}
		return m, nil
	case "c":
		if !m.firstLaunch {
			m.studentModal = false
			m.numberInput = ""
			m.inputErr = ""
		}
		return m, nil
	}
	if len(msg.Text) == 1 && msg.Text[0] >= '0' && msg.Text[0] <= '9' && len(m.numberInput) < 3 {
		m.numberInput += msg.Text
	}
	return m, nil
}

func (m Model) handleActivitiesKey(key string) (tea.Model, tea.Cmd) {
	switch key {
	case "esc":
		return m, tea.Quit
	case "u":
		m.studentModal = true
		m.numberInput = ""
		m.inputErr = ""
		return m, nil
	case "up", "k":
		if m.activeActivity > 0 {
			m.activeActivity--
		}
		return m, nil
	case "down", "j":
		if m.activeActivity < len(m.activities)-1 {
			m.activeActivity++
		}
		return m, nil
	case "enter":
		if len(m.activities) == 0 {
			return m, nil
		}
		m.screen = screenActivity
		m.selected = 0
		return m, nil
	}
	return m, nil
}

func (m Model) handleActivityKey(key string) (tea.Model, tea.Cmd) {
	act := m.activities[m.activeActivity]
	rows := flatten(act)

	switch key {
	case "esc":
		return m, tea.Quit
	case "u":
		m.studentModal = true
		m.numberInput = ""
		m.inputErr = ""
		return m, nil
	case "c":
		m.screen = screenActivities
		return m, nil
	case "up", "k":
		if m.selected > 0 {
			m.selected--
		}
		return m, nil
	case "down", "j":
		if m.selected < len(rows)-1 {
			m.selected++
		}
		return m, nil
	case "t":
		if len(rows) == 0 || m.running {
			return m, nil
		}
		r := rows[m.selected]
		test := act.Sections[r.section].Tests[r.test]
		content, err := os.ReadFile(test.ScriptPath)
		if err != nil {
			m.scriptContent = fmt.Sprintf("No s'ha pogut llegir l'script: %v", err)
		} else {
			m.scriptContent = string(content)
		}
		m.scriptScroll = 0
		m.scriptPopup = true
		return m, nil
	case "enter":
		if len(rows) == 0 || m.running {
			return m, nil
		}
		r := rows[m.selected]
		test := act.Sections[r.section].Tests[r.test]
		key := testKey{activity: m.activeActivity, section: r.section, test: r.test}
		m.running = true
		m.runningKey = key
		return m, runTestCmd(key, test.ScriptPath, act.RootDir, m.cfg.StudentNumber, timeoutDuration(m.cfg))
	case "a":
		if len(rows) == 0 || m.running {
			return m, nil
		}
		section := rows[m.selected].section
		var queue []testKey
		for ti := range act.Sections[section].Tests {
			queue = append(queue, testKey{activity: m.activeActivity, section: section, test: ti})
		}
		if len(queue) == 0 {
			return m, nil
		}
		m.batchActive = true
		m.batchQueue = queue
		m.batchIdx = 0
		m.running = true
		m.runningKey = queue[0]
		test := act.Sections[section].Tests[queue[0].test]
		return m, runTestCmd(queue[0], test.ScriptPath, act.RootDir, m.cfg.StudentNumber, timeoutDuration(m.cfg))
	}
	return m, nil
}

func (m Model) handleScriptPopupKey(key string) (tea.Model, tea.Cmd) {
	switch key {
	case "esc":
		return m, tea.Quit
	case "t", "c":
		m.scriptPopup = false
		return m, nil
	case "up", "k":
		if m.scriptScroll > 0 {
			m.scriptScroll--
		}
		return m, nil
	case "down", "j":
		m.scriptScroll++
		return m, nil
	}
	return m, nil
}

func (m Model) handleTestFinished(msg testFinishedMsg) (tea.Model, tea.Cmd) {
	m.results[msg.key] = msg.result

	if m.batchActive {
		m.batchIdx++
		if m.batchIdx < len(m.batchQueue) {
			next := m.batchQueue[m.batchIdx]
			act := m.activities[next.activity]
			test := act.Sections[next.section].Tests[next.test]
			m.runningKey = next
			return m, runTestCmd(next, test.ScriptPath, act.RootDir, m.cfg.StudentNumber, timeoutDuration(m.cfg))
		}
		m.batchActive = false
		m.batchQueue = nil
		m.batchIdx = 0
	}
	m.running = false
	return m, nil
}

func runTestCmd(key testKey, scriptPath, workDir string, student int, timeout time.Duration) tea.Cmd {
	return func() tea.Msg {
		return testFinishedMsg{key: key, result: runner.Run(scriptPath, workDir, student, timeout)}
	}
}

func timeoutDuration(cfg config.Config) time.Duration {
	return time.Duration(cfg.TimeoutSeconds) * time.Second
}

func flatten(act activity.Activity) []rowRef {
	var rows []rowRef
	for si, sec := range act.Sections {
		for ti := range sec.Tests {
			rows = append(rows, rowRef{section: si, test: ti})
		}
	}
	return rows
}
