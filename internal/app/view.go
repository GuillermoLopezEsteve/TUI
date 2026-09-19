package app

import (
	"fmt"
	"strconv"
	"strings"

	tea "charm.land/bubbletea/v2"
	lipgloss "charm.land/lipgloss/v2"

	"labcheck/internal/activity"
	"labcheck/internal/highlight"
	"labcheck/internal/i18n"
	"labcheck/internal/runner"
)

var (
	titleStyle    = lipgloss.NewStyle().Bold(true)
	dimStyle      = lipgloss.NewStyle().Foreground(lipgloss.Color("8"))
	selectedStyle = lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("13"))
	passedStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("2")).Bold(true)
	failedStyle   = lipgloss.NewStyle().Foreground(lipgloss.Color("1")).Bold(true)
	errStyle      = lipgloss.NewStyle().Foreground(lipgloss.Color("1"))
	helpStyle     = lipgloss.NewStyle().Foreground(lipgloss.Color("8"))
	boxStyle      = lipgloss.NewStyle().Border(lipgloss.RoundedBorder()).Padding(0, 1)
)

func (m Model) View() tea.View {
	var body string
	switch {
	case m.studentModal:
		body = m.viewStudentModal()
	case m.scriptPopup:
		body = m.viewScriptPopup()
	case m.screen == screenActivities:
		body = m.viewActivities()
	default:
		body = m.viewActivity()
	}

	v := tea.NewView(body)
	v.AltScreen = true
	return v
}

func (m Model) studentDisplay() string {
	if m.cfg.StudentNumber == 0 {
		return i18n.StudentUnset
	}
	return strconv.Itoa(m.cfg.StudentNumber)
}

func (m Model) header(title string) string {
	return fmt.Sprintf("%s   %s: %s", title, i18n.StudentLabel, m.studentDisplay())
}

func (m Model) viewStudentModal() string {
	lines := []string{
		titleStyle.Render(i18n.SetStudentTitle),
		"",
		fmt.Sprintf("%s %s_", i18n.NumberPromptLabel, m.numberInput),
	}
	if m.inputErr != "" {
		lines = append(lines, "", errStyle.Render(m.inputErr))
	}

	help := i18n.HelpStudentModal
	if m.firstLaunch {
		help = i18n.HelpStudentFirstLaunch
	}

	box := boxStyle.Render(strings.Join(lines, "\n"))
	return m.header(i18n.AppName) + "\n\n" + box + "\n\n" + helpStyle.Render(help)
}

func (m Model) viewActivities() string {
	var b strings.Builder
	b.WriteString(titleStyle.Render(i18n.ActivitiesTitle))
	b.WriteString("\n\n")

	if len(m.activities) == 0 {
		msg := fmt.Sprintf(i18n.NoActivities, m.activitiesDir)
		if m.activitiesErr != nil {
			msg += "\n" + m.activitiesErr.Error()
		}
		b.WriteString(dimStyle.Render(msg))
	} else {
		for i, act := range m.activities {
			cursor := "  "
			style := lipgloss.NewStyle()
			if i == m.activeActivity {
				cursor = "> "
				style = selectedStyle
			}
			line := fmt.Sprintf("%s%-28s %s", cursor, act.Title, act.Description)
			b.WriteString(style.Render(line))
			b.WriteString("\n")
		}
	}

	return m.header(i18n.AppName) + "\n\n" + b.String() + "\n" + helpStyle.Render(i18n.HelpActivities)
}

// viewActivity renders a permanent split screen: the section/test list on
// the left, and the highlighted test's title, description and result (if
// executed) on the right.
func (m Model) viewActivity() string {
	act := m.activities[m.activeActivity]

	totalWidth := m.width
	if totalWidth <= 0 {
		totalWidth = 100
	}
	listWidth := totalWidth * 2 / 5
	if listWidth < 28 {
		listWidth = 28
	}
	detailWidth := totalWidth - listWidth - 6 // borders + gap
	if detailWidth < 24 {
		detailWidth = 24
	}

	// Inner content width: boxStyle adds a 1-cell border plus 1-cell padding
	// on each side.
	innerListWidth := listWidth - 4
	innerDetailWidth := detailWidth - 4

	listLines, selectedLine := m.testListLines(act, innerListWidth)
	detailLines := strings.Split(lipgloss.NewStyle().Width(innerDetailWidth).Render(m.renderTestDetail(act)), "\n")

	// Reserve the screen rows used outside the box so the box itself never
	// exceeds the terminal height: header(1) + blank(1) + border top/bottom(2)
	// + blank(1) + help(1). Without this, a list taller than the terminal
	// just runs off the bottom edge with no way to scroll to it.
	const chrome = 6
	availableHeight := m.height - chrome
	if availableHeight < 3 {
		// Unknown or tiny terminal (e.g. before the first WindowSizeMsg):
		// fall back to showing the full content, as before.
		availableHeight = max(len(listLines), len(detailLines), 3)
	}

	paneHeight := min(max(len(listLines), len(detailLines)), availableHeight)

	listWindow := strings.Join(windowAround(listLines, selectedLine, paneHeight), "\n")
	detailWindow := strings.Join(windowTop(detailLines, paneHeight), "\n")

	// boxStyle's border adds 2 rows (top+bottom); Style.Height() counts them,
	// so we pad the target by 2 to get paneHeight content rows inside.
	const borderRows = 2
	left := boxStyle.Width(listWidth).Height(paneHeight + borderRows).Render(listWindow)
	right := boxStyle.Width(detailWidth).Height(paneHeight + borderRows).Render(detailWindow)
	body := lipgloss.JoinHorizontal(lipgloss.Top, left, right)

	help := i18n.HelpActivity
	if m.batchActive {
		help = i18n.BatchBusy + "   " + help
	}

	return m.header(act.Title) + "\n\n" + body + "\n\n" + helpStyle.Render(help)
}

// windowAround returns at most height consecutive lines from lines, scrolled
// so that the line at index center is visible. Centering it (rather than
// only nudging the window by the minimum needed) is a stateless rule that
// needs no persisted scroll offset: it depends only on the current
// selection, yet still keeps the cursor on screen as it moves.
func windowAround(lines []string, center, height int) []string {
	if height >= len(lines) {
		return lines
	}
	if height <= 0 {
		return nil
	}
	maxStart := len(lines) - height
	start := center - height/2
	if start < 0 {
		start = 0
	}
	if start > maxStart {
		start = maxStart
	}
	return lines[start : start+height]
}

// windowTop returns at most the first height lines from lines.
func windowTop(lines []string, height int) []string {
	if height >= len(lines) {
		return lines
	}
	if height <= 0 {
		return nil
	}
	return lines[:height]
}

func (m Model) statusSymbol(key testKey) string {
	if m.running && m.runningKey == key {
		return dimStyle.Render("…")
	}
	res, ok := m.results[key]
	if !ok {
		return "○"
	}
	if res.Status == runner.StatusPassed {
		return passedStyle.Render("✓")
	}
	return failedStyle.Render("✗")
}

// testListLines renders the section/test tree as one string per row,
// truncating (never wrapping) titles to fit width so each row stays a single
// line. It also returns the row index of the currently selected test, so the
// caller can scroll the list to keep it visible.
func (m Model) testListLines(act activity.Activity, width int) (lines []string, selectedLine int) {
	flat := 0
	for si, sec := range act.Sections {
		lines = append(lines, titleStyle.Render(truncate(sec.Title, width)))
		for ti, test := range sec.Tests {
			key := testKey{activity: m.activeActivity, section: si, test: ti}
			symbol := m.statusSymbol(key)

			cursor := "  "
			style := lipgloss.NewStyle()
			if flat == m.selected {
				cursor = "> "
				style = selectedStyle
				selectedLine = len(lines)
			}
			title := truncate(test.Title, width-4) // cursor(2) + symbol(1) + space(1)
			line := fmt.Sprintf("%s%s %s", cursor, symbol, title)
			lines = append(lines, style.Render(line))
			flat++
		}
		lines = append(lines, "")
	}
	if len(lines) > 0 {
		lines = lines[:len(lines)-1] // drop the trailing blank separator
	}
	return lines, selectedLine
}

func (m Model) renderTestDetail(act activity.Activity) string {
	rows := flatten(act)
	if len(rows) == 0 || m.selected >= len(rows) {
		return dimStyle.Render(i18n.NotSelected)
	}
	r := rows[m.selected]
	test := act.Sections[r.section].Tests[r.test]
	key := testKey{activity: m.activeActivity, section: r.section, test: r.test}

	var b strings.Builder
	b.WriteString(titleStyle.Render(test.Title))
	b.WriteString("\n\n")
	b.WriteString(test.Description)
	b.WriteString("\n\n")

	switch {
	case m.running && m.runningKey == key:
		b.WriteString(dimStyle.Render(i18n.RunningLabel))
	default:
		if res, ok := m.results[key]; ok {
			if res.Status == runner.StatusPassed {
				b.WriteString(passedStyle.Render(i18n.TestPassed))
			} else {
				b.WriteString(failedStyle.Render(res.Message))
			}
		} else {
			b.WriteString(dimStyle.Render("○"))
		}
	}

	return b.String()
}

// truncate shortens s to fit within width visible cells, appending an
// ellipsis when it doesn't fit. Used to keep list rows to one line each.
func truncate(s string, width int) string {
	if width <= 0 {
		return ""
	}
	if lipgloss.Width(s) <= width {
		return s
	}
	if width <= 1 {
		return "…"
	}
	runes := []rune(s)
	for len(runes) > 0 {
		candidate := string(runes) + "…"
		if lipgloss.Width(candidate) <= width {
			return candidate
		}
		runes = runes[:len(runes)-1]
	}
	return "…"
}

func (m Model) viewScriptPopup() string {
	act := m.activities[m.activeActivity]
	rows := flatten(act)

	var path string
	if len(rows) > 0 && m.selected < len(rows) {
		r := rows[m.selected]
		path = act.Sections[r.section].Tests[r.test].ScriptPath
	}

	highlighted := highlight.Render(m.scriptContent)
	lines := strings.Split(highlighted, "\n")

	visible := m.height - 8
	if visible < 5 {
		visible = 5
	}
	start := m.scriptScroll
	if start > len(lines)-1 {
		start = max(0, len(lines)-1)
	}
	end := min(start+visible, len(lines))
	windowed := strings.Join(lines[start:end], "\n")

	body := dimStyle.Render(path) + "\n\n" + windowed
	box := boxStyle.Render(titleStyle.Render(i18n.ScriptPopupTitle) + "\n\n" + body)
	return box + "\n\n" + helpStyle.Render(i18n.HelpScriptPopup)
}
