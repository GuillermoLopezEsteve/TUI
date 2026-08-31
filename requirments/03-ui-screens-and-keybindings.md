# LabCheck: UI Screens and Keybindings

**Document status:** UI specification
**Related documents:**

- [Overview](./00-overview.md)
- [Runner and config](./02-runner-and-config.md)

All screen text below is shown in English for spec-writing clarity; the shipped application
must render it in Catalan (see [language requirement](./00-overview.md#5-language-requirement)).

## 1. Screen 1 — Student number

Shown automatically on first launch if `config` has no `student_number`, and reopened as a
modal overlay from any screen by pressing `U`.

```text
┌──────────────────────────────────────────────────────────────┐
│ LabCheck                                      Student: unset │
│                                                              │
│                  Set student number                          │
│                                                              │
│                  Number [1–100]: 42_                         │
│                                                              │
│             Enter save   C cancel   Esc quit                 │
└──────────────────────────────────────────────────────────────┘
```

- On first launch, cancel is disabled — a valid number is required before continuing.
- On later use via `U`, `C` closes the modal without saving.
- Saving a changed number clears all in-memory results for the current session.

## 2. Screen 2 — Activities list

```text
┌─────────────────────────────────────────────────────────────────────────┐
│ LabCheck                                                   Student: 42 │
├─────────────────────────────────────────────────────────────────────────┤
│ Activities                                                              │
│                                                                         │
│ > DHCP                     Address allocation and configuration         │
│   DNS                      Zones, records and resolution                │
│   Mail server               SMTP, IMAP and log verification              │
│                                                                         │
├─────────────────────────────────────────────────────────────────────────┤
│ ↑/↓ move   Enter open   U student   C back   Esc/Ctrl+C quit            │
└─────────────────────────────────────────────────────────────────────────┘
```

`Enter` opens the selected activity, landing on Screen 3.

## 3. Screen 3 — Activity screen (permanent split view)

Both panes are always visible side by side — there is no tab to switch between them. The
left pane shows the section/test tree; the right pane always reflects whatever test is
currently highlighted on the left.

```text
┌────────────────────────────────────┐┌──────────────────────────────────────────────────┐
│ Configuration                      ││ File permissions are correct                     │
│   ✓ Config file exists            ││                                                    │
│ > ✗ File permissions are correct  ││ Checks that /etc/dhcp/dhcpd.conf is owned by      │
│                                    ││ root and not world-writable.                      │
│ IP allocation                      ││                                                    │
│   ○ Client receives the correct   ││ FAILED                                            │
│   IP                               ││ Expected mode 644, found 666.                     │
└────────────────────────────────────┘└──────────────────────────────────────────────────┘
DHCP   Student: 42
Enter run test   a run section   t view script   U student   C back
```

- The left pane lists sections as headings with their tests indented underneath, each
  prefixed by its status symbol. Rows never wrap — a title too long for the pane is
  truncated with an ellipsis, per the [responsive behavior](#7-responsive-behavior) rule
  already in place for narrow layouts.
- The right pane shows the highlighted test's title, description, and — once it has been
  run — its result: the fixed string `TEST PASSED` in green (`PROVA SUPERADA` in the shipped
  Catalan UI) on a pass, or the captured failure message in red on a fail (including a
  timeout). Moving the selection in the left pane updates the right pane immediately.
- Both panes are rendered at equal height (matched to whichever pane's content is taller)
  so the split renders as one clean rectangle rather than two mismatched boxes.

## 4. Status symbols

| Symbol | Status |
|---|---|
| `○` | Not tested |
| `✓` | Passed (green) |
| `✗` | Failed (red) |

## 5. Keybindings

| Key | Action |
|---|---|
| `Enter` | Run the highlighted test. |
| `a` | Run every test in the current section. |
| `t` | Open a read-only popup with the highlighted test's script. Press `t` again (or the back key) to close it. |
| `U` | Open/reopen the student-number screen. |
| `C` | Go back one level. *(Carried over from the earlier design as a default — adjust if desired.)* |
| `Esc` / `Ctrl+C` | Quit, restoring the terminal. *(Same as above — default, adjustable.)* |
| `↑` / `↓` | Move the selection within the current list. |

Key matching should be case-insensitive for single-letter commands; the help bar displays
uppercase labels for readability, consistent with the rest of the UI.

## 6. Script popup and highlighting

```text
┌──────────────────────── Test script ──────────────────────────┐
│ dhcp/configuracio/permisos-fitxer.sh                          │
│                                                                │
│ #!/bin/bash                                                   │
│ # TITLE: El fitxer de configuració existeix                   │
│ # DESCRIPTION: Comprova que ...                                │
│ if [[ ! -r /etc/dhcp/dhcpd.conf ]]; then                       │
│ ...                                                            │
│                                                                │
│ ↑/↓ scroll   t/C close                                        │
└──────────────────────────────────────────────────────────────┘
```

Highlighting — exactly three rules, applied in a single lexical pass that never changes the
displayed characters (a display aid only, not a Bash parser):

1. Recognized Bash keywords (`if then elif else fi for while until do done case esac in
   function`, etc.) → **green**.
2. Text inside `"..."` → **yellow**.
3. A comment, from an unescaped `#` to end of line → **cyan**.
4. Everything else → default foreground color.

This deliberately omits the older design's bracket-region highlighting — three rules only,
per the [guiding principle](./00-overview.md#2-guiding-principle-keep-it-simple).

## 7. Responsive behavior

- The left pane's width is a fraction of the terminal width (roughly two-fifths, with a
  sensible minimum); the right pane takes the remainder. List rows that don't fit are
  truncated with an ellipsis rather than wrapped, so the pane's height stays predictable.
- At very small terminal sizes, show a minimum-size warning while still allowing quit.
