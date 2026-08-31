# LabCheck: Activities, Tests and Authoring

**Document status:** Activity-format specification
**Related documents:**

- [Overview](./00-overview.md)
- [Runner and config](./02-runner-and-config.md)

## 1. Purpose

Activities are defined entirely on disk — as folders, a tiny `meta` file per folder, and
Bash test scripts with a parsed comment header. There is no YAML manifest: adding or editing
a lab means adding or editing files, nothing else.

## 2. Directory layout

```text
activitats/
└── dhcp/
    ├── meta
    ├── configuracio/
    │   ├── meta
    │   ├── fitxer-existeix.sh
    │   └── permisos-fitxer.sh
    └── concessio-ip/
        ├── meta
        └── ip-correcta.sh
```

Rules:

- The top level of `activitats/` is the list of activities; each subfolder is one activity.
- Each activity folder contains a `meta` file and one subfolder per section.
- Each section folder contains a `meta` file and one or more `.sh` test scripts.
- Folder names are lowercase kebab-case; they are not shown directly to the student (the
  `meta` file's `TITLE` is), so they can stay short and ASCII-only.
- Tests and sections are listed in the order the filesystem returns them — authors should
  name files so that a plain alphabetical sort matches the intended teaching order (e.g.
  `01-fitxer-existeix.sh`, `02-permisos-fitxer.sh`, if ordering matters).

## 3. `meta` file format

One `meta` file per activity folder and per section folder. Plain text, exactly two lines:

```text
TITLE: Servidor DHCP
DESCRIPTION: Configura un servidor DHCP que assigni adreces correctament.
```

Parsing rule: the text after `TITLE:` (trimmed) is the display title; the text after
`DESCRIPTION:` (trimmed) is the display description. Both are shown to the student in
Catalan, matching the [language requirement](./00-overview.md#5-language-requirement) — the
`meta` file content itself must be written in Catalan since it is displayed as-is.

## 4. Test script format

Every test is one `.sh` file. Its title and description live as a comment header
immediately after the shebang, one line each:

```bash
#!/bin/bash
# TITLE: El fitxer de configuració existeix
# DESCRIPTION: Comprova que /etc/dhcp/dhcpd.conf existeixi i sigui llegible.

if [[ ! -r /etc/dhcp/dhcpd.conf ]]; then
    echo "Falta el fitxer /etc/dhcp/dhcpd.conf o no es pot llegir."
    exit 1
fi

exit 0
```

Parsing rule: the loader reads the file's first lines, looks for a line starting with
`# TITLE:` and a line starting with `# DESCRIPTION:` (in either order, but conventionally
right after the shebang), and takes the trimmed remainder of each as the value. Keep both to
a single line — this is intentionally simple to parse, not a general front-matter format.

Like `meta` files, `TITLE`/`DESCRIPTION` text must be written in Catalan.

## 5. What a good test checks

Directly from the product intent: tests should be small, guiding checks a student can read
and understand, not an exhaustive grading suite. Typical atomic checks:

- A file exists.
- A file has the correct read/write permissions.
- A file belongs to the correct user/group.
- An interface or service has the correct IP address.
- The machine has internet connectivity.
- A given server/package is installed.
- A given server/service is running.

One test = one of the above, for one resource. If describing a test needs "and" to join two
independent facts, split it into two tests.

## 6. Script execution contract

- Invocation: `/bin/bash --noprofile --norc <script> <student_number>` — never `sh -c` or a
  string-built command, to avoid injection and keep behavior predictable.
- The student number is passed as `$1`. Scripts read it directly:
  ```bash
  student_number="${1:?missing student number}"
  ```
- Standard input is connected to `/dev/null`; a script must never prompt for input.
- The working directory is the activity's root folder.

## 7. Result-reporting convention

The result model is deliberately three states only — see
[Runner and config](./02-runner-and-config.md#4-result-states) — so the contract scripts
must follow is simple:

- **Exit `0`** → the test passed. Whatever the script printed is ignored; the UI always
  shows the fixed Catalan string for "test passed" (`PROVA SUPERADA`).
- **Any non-zero exit** → the test failed (this also covers a timeout — the runner kills the
  process and treats it the same as a non-zero exit, with its own explanatory message; see
  [Runner and config](./02-runner-and-config.md)). On failure, the script should print one
  plain-text line explaining what was wrong, e.g.:
  ```bash
  echo "S'esperava 192.168.10.50 però s'ha trobat 192.168.10.51."
  exit 1
  ```
  The runner takes the **last non-empty line** printed by the script (stdout or stderr) and
  shows it as the failure message in the detail tab, in red.

## 8. Author checklist

- [ ] The activity folder and every section folder has a `meta` file with `TITLE`/`DESCRIPTION`.
- [ ] Every test script has a `# TITLE:` and `# DESCRIPTION:` line after the shebang.
- [ ] Every test checks exactly one fact.
- [ ] The script reads the student number from `$1`.
- [ ] The script prints one clear line explaining the problem before a non-zero exit.
- [ ] The script does not request interactive input.
- [ ] The script does not modify the student's system.
- [ ] All student-facing text (`meta` files, `TITLE`/`DESCRIPTION`, failure messages) is in
      Catalan.
- [ ] The script comfortably finishes well within the global 60-second timeout.
