// Package highlight is LabCheck's deliberately simple, three-rule Bash
// syntax highlighter for the script popup. It is a display aid, not a
// parser: it never changes the underlying text.
package highlight

import (
	"strings"

	lipgloss "charm.land/lipgloss/v2"
)

var (
	keywordStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("2")) // green
	stringStyle  = lipgloss.NewStyle().Foreground(lipgloss.Color("3")) // yellow
	commentStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("6")) // cyan
)

var keywords = map[string]bool{
	"if": true, "then": true, "elif": true, "else": true, "fi": true,
	"for": true, "while": true, "until": true, "do": true, "done": true,
	"case": true, "esac": true, "in": true, "function": true,
	"select": true, "time": true,
}

// Render highlights a complete script, one line at a time.
func Render(source string) string {
	lines := strings.Split(source, "\n")
	for i, l := range lines {
		lines[i] = line(l)
	}
	return strings.Join(lines, "\n")
}

func line(s string) string {
	var b strings.Builder
	i := 0
	for i < len(s) {
		switch s[i] {
		case '#':
			b.WriteString(commentStyle.Render(s[i:]))
			return b.String()
		case '"':
			j := i + 1
			for j < len(s) && s[j] != '"' {
				j++
			}
			if j < len(s) {
				j++ // include the closing quote
			}
			b.WriteString(stringStyle.Render(s[i:j]))
			i = j
		default:
			j := i
			for j < len(s) && isWordChar(s[j]) {
				j++
			}
			if j == i {
				b.WriteByte(s[i])
				i++
				continue
			}
			word := s[i:j]
			if keywords[word] {
				b.WriteString(keywordStyle.Render(word))
			} else {
				b.WriteString(word)
			}
			i = j
		}
	}
	return b.String()
}

func isWordChar(c byte) bool {
	return c == '_' ||
		(c >= 'a' && c <= 'z') ||
		(c >= 'A' && c <= 'Z') ||
		(c >= '0' && c <= '9')
}
