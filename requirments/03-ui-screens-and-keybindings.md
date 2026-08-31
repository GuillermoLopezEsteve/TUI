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

## 3. Screen 3 — Activity screen (two tabs)

### Tab "List"

Tree of sections → tests, each line prefixed with its status symbol.

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│ DHCP                                                   Student: 42  [List]   │
├──────────────────────────────────────────────────────────────────────────────┤
│ Configuration                                                                │
│   ✓ Config file exists                                                      │
│ > ✗ File permissions are correct                                            │
│                                                                                │
│ IP allocation                                                                │
│   ○ Client receives the correct IP                                          │
│                                                                                │
├──────────────────────────────────────────────────────────────────────────────┤
│ Enter run test   a run section   t view script   Tab switch   U student   C back │
└──────────────────────────────────────────────────────────────────────────────┘
```

### Tab "Detail"

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│ DHCP                                                   Student: 42  [Detail] │
├──────────────────────────────────────────────────────────────────────────────┤
│ File permissions are correct                                                 │
│                                                                                │
│ Checks that /etc/dhcp/dhcpd.conf is owned by root and not world-writable.    │
│                                                                                │
│ FAILED                                                                        │
│ Expected mode 644, found 666.                                                │
│                                                                                │
├──────────────────────────────────────────────────────────────────────────────┤
│ Enter run test   a run section   t view script   Tab switch   U student   C back │
└──────────────────────────────────────────────────────────────────────────────┘
```

- On a passed test, the result line shows the fixed string `TEST PASSED` in green
  (`PROVA SUPERADA` in the shipped Catalan UI) instead of any script output.
- On a failed test (including a timeout), the result line shows the captured failure message
  in red.

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
| `Tab` | Switch between the "List" and "Detail" tabs. *(Not specified in the original dictation — carried over as a sensible default; adjust if you'd rather use, e.g., left/right arrows.)* |
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

- At widths of roughly 100 columns or more, render the activity screen's list comfortably;
  below that, prioritize the current tab's content over decoration and let long lines wrap.
- At very small terminal sizes, show a minimum-size warning while still allowing quit.
