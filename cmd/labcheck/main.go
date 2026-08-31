// Command labcheck runs the LabCheck TUI.
package main

import (
	"fmt"
	"os"

	tea "charm.land/bubbletea/v2"

	"labcheck/internal/app"
)

func main() {
	p := tea.NewProgram(app.New())
	if _, err := p.Run(); err != nil {
		fmt.Fprintln(os.Stderr, "labcheck:", err)
		os.Exit(1)
	}
}
