// Package runner executes one test script under a hard timeout and
// classifies the outcome into LabCheck's three-state result model.
package runner

import (
	"bytes"
	"context"
	"fmt"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"syscall"
	"time"
)

// Status is the three-state result model: no "error" or "timed out" state is
// surfaced separately — both are reported as Failed with an explanatory
// message.
type Status int

const (
	StatusNotTested Status = iota
	StatusPassed
	StatusFailed
)

// Result is the outcome of running one test.
type Result struct {
	Status   Status
	Message  string // shown for Failed; ignored (fixed "passed" text used) for Passed
	Duration time.Duration
}

// Run invokes the test script directly with Bash (never sh -c), passing the
// student number as $1, and kills the whole process group if it exceeds
// timeout. workDir is the activity's root directory, used as the script's
// working directory.
func Run(scriptPath, workDir string, studentNumber int, timeout time.Duration) Result {
	start := time.Now()

	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	// Resolve to an absolute path: cmd.Dir changes the child's working
	// directory, so a relative scriptPath would otherwise be looked up
	// relative to workDir instead of the caller's cwd.
	absScript, err := filepath.Abs(scriptPath)
	if err != nil {
		absScript = scriptPath
	}

	cmd := exec.CommandContext(ctx, "/bin/bash", "--noprofile", "--norc",
		absScript, strconv.Itoa(studentNumber))
	cmd.Dir = workDir
	cmd.Stdin = nil
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}

	// Ensure the whole process group is killed on timeout, not just the
	// direct Bash process, so any subprocess the script spawned dies too.
	cmd.Cancel = func() error {
		if cmd.Process == nil {
			return nil
		}
		return syscall.Kill(-cmd.Process.Pid, syscall.SIGKILL)
	}

	var out bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = &out

	err = cmd.Run()
	duration := time.Since(start)

	if ctx.Err() == context.DeadlineExceeded {
		return Result{
			Status:   StatusFailed,
			Message:  fmt.Sprintf("El test ha superat el temps límit de %d segons.", int(timeout.Seconds())),
			Duration: duration,
		}
	}

	if err == nil {
		return Result{Status: StatusPassed, Duration: duration}
	}

	msg := lastNonEmptyLine(out.String())
	if msg == "" {
		msg = "El test ha fallat sense cap missatge."
	}
	return Result{Status: StatusFailed, Message: msg, Duration: duration}
}

func lastNonEmptyLine(s string) string {
	lines := strings.Split(strings.TrimRight(s, "\n"), "\n")
	for i := len(lines) - 1; i >= 0; i-- {
		if line := strings.TrimSpace(lines[i]); line != "" {
			return line
		}
	}
	return ""
}
