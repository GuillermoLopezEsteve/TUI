// Package activity scans the activitats/ directory tree: activities and
// sections are folders with a "meta" file, tests are ".sh" scripts with a
// comment header. There is no YAML manifest.
package activity

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// TestCase is one atomic Bash check.
type TestCase struct {
	ID          string
	Title       string
	Description string
	ScriptPath  string
}

// Section groups related tests within an activity.
type Section struct {
	ID          string
	Title       string
	Description string
	Tests       []TestCase
}

// Activity is one complete lab.
type Activity struct {
	ID          string
	Title       string
	Description string
	Sections    []Section
	RootDir     string
}

// FindRoot resolves the activities directory: the LABCHECK_ACTIVITIES_DIR
// environment variable, an "activitats" folder next to the current working
// directory, or one next to the running binary.
func FindRoot() (string, error) {
	if v := os.Getenv("LABCHECK_ACTIVITIES_DIR"); v != "" {
		return v, nil
	}

	candidates := []string{"activitats"}
	if exe, err := os.Executable(); err == nil {
		candidates = append(candidates, filepath.Join(filepath.Dir(exe), "activitats"))
	}

	for _, c := range candidates {
		if info, err := os.Stat(c); err == nil && info.IsDir() {
			return c, nil
		}
	}
	return "", fmt.Errorf("no activities directory found (tried %v)", candidates)
}

// Load scans root for activity folders, each containing section folders,
// each containing ".sh" test scripts. Invalid or incomplete entries are
// skipped rather than aborting the whole scan.
func Load(root string) ([]Activity, error) {
	entries, err := os.ReadDir(root)
	if err != nil {
		return nil, err
	}

	var activities []Activity
	for _, e := range entries {
		if !e.IsDir() {
			continue
		}
		actDir := filepath.Join(root, e.Name())

		title, desc, err := readMetaFile(filepath.Join(actDir, "meta"))
		if err != nil {
			continue
		}

		sections, err := loadSections(actDir)
		if err != nil || len(sections) == 0 {
			continue
		}

		activities = append(activities, Activity{
			ID:          e.Name(),
			Title:       title,
			Description: desc,
			Sections:    sections,
			RootDir:     actDir,
		})
	}
	return activities, nil
}

func loadSections(actDir string) ([]Section, error) {
	entries, err := os.ReadDir(actDir)
	if err != nil {
		return nil, err
	}

	var sections []Section
	for _, e := range entries {
		if !e.IsDir() {
			continue
		}
		secDir := filepath.Join(actDir, e.Name())

		title, desc, err := readMetaFile(filepath.Join(secDir, "meta"))
		if err != nil {
			continue
		}

		tests, err := loadTests(secDir)
		if err != nil || len(tests) == 0 {
			continue
		}

		sections = append(sections, Section{
			ID:          e.Name(),
			Title:       title,
			Description: desc,
			Tests:       tests,
		})
	}
	return sections, nil
}

func loadTests(secDir string) ([]TestCase, error) {
	entries, err := os.ReadDir(secDir)
	if err != nil {
		return nil, err
	}

	var tests []TestCase
	for _, e := range entries {
		if e.IsDir() || !strings.HasSuffix(e.Name(), ".sh") {
			continue
		}
		scriptPath := filepath.Join(secDir, e.Name())

		title, desc, err := readTestHeader(scriptPath)
		if err != nil {
			continue
		}

		tests = append(tests, TestCase{
			ID:          strings.TrimSuffix(e.Name(), ".sh"),
			Title:       title,
			Description: desc,
			ScriptPath:  scriptPath,
		})
	}
	return tests, nil
}

// readMetaFile parses an activity/section "meta" file: two plain-text lines,
// "TITLE: ..." and "DESCRIPTION: ...".
func readMetaFile(path string) (title, description string, err error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return "", "", err
	}
	for _, line := range strings.Split(string(data), "\n") {
		line = strings.TrimSpace(line)
		switch {
		case strings.HasPrefix(line, "TITLE:"):
			title = strings.TrimSpace(strings.TrimPrefix(line, "TITLE:"))
		case strings.HasPrefix(line, "DESCRIPTION:"):
			description = strings.TrimSpace(strings.TrimPrefix(line, "DESCRIPTION:"))
		}
	}
	if title == "" {
		return "", "", fmt.Errorf("%s: missing TITLE", path)
	}
	return title, description, nil
}

// readTestHeader parses a test script's "# TITLE:" / "# DESCRIPTION:"
// comment header, expected within the first lines after the shebang.
func readTestHeader(path string) (title, description string, err error) {
	f, err := os.Open(path)
	if err != nil {
		return "", "", err
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	for lines := 0; scanner.Scan() && lines < 20; lines++ {
		line := strings.TrimSpace(scanner.Text())
		switch {
		case strings.HasPrefix(line, "# TITLE:"):
			title = strings.TrimSpace(strings.TrimPrefix(line, "# TITLE:"))
		case strings.HasPrefix(line, "# DESCRIPTION:"):
			description = strings.TrimSpace(strings.TrimPrefix(line, "# DESCRIPTION:"))
		}
	}
	if err := scanner.Err(); err != nil {
		return "", "", err
	}
	if title == "" {
		return "", "", fmt.Errorf("%s: missing # TITLE:", path)
	}
	return title, description, nil
}
