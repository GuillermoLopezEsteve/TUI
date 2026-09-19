# LabCheck (smx2-checker)

A terminal app for SMX2 lab activities: it runs instructor-authored checks against your
machine (DHCP, DNS, etc.) and tells you, per check, what's correct and what isn't. It doesn't
configure anything for you — it just tells you where you stand.

Requires Linux and a terminal. All in-app text is in Catalan.

## 1. Download

You need [Go](https://go.dev/dl/) 1.25 or later installed (`go version` to check).

**With git (recommended):**

```bash
git clone https://github.com/GuillermoLopezEsteve/TUI.git
cd TUI
```

**With curl, if git isn't installed:**

```bash
curl -L https://github.com/GuillermoLopezEsteve/TUI/archive/refs/heads/master.tar.gz -o tui.tar.gz
tar xzf tui.tar.gz
cd TUI-master
```

## 2. Build and install `smx2-checker`

From inside the downloaded folder:

```bash
make install
```

This builds the app and drops a small `smx2-checker` script into `~/.local/bin`, so you can
run it as a normal command from any directory. No `sudo` needed.

If `~/.local/bin` isn't already on your `PATH`, `make install` tells you so and prints the
line to add to `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Add it, then open a new terminal (or run `source ~/.bashrc`).

## 3. Run it

```bash
smx2-checker
```

On first launch it asks for your student number (1–100), then shows the list of activities.
Basic keys, shown at the bottom of each screen:

- `↑`/`↓` — move
- `Enter` — open an activity / run the highlighted test
- `a` — run every test in the highlighted section
- `t` — view a test's script
- `U` — change your student number
- `C` — go back
- `Esc` / `Ctrl+C` — quit

## Updating

```bash
cd TUI      # the folder you cloned into
git pull
make install
```

`make install` always rebuilds first, so this picks up both code and activity changes.

## Uninstalling

```bash
make uninstall
```

## More detail

The full activity format and runner design are documented under
[`requirments/`](./requirments/00-overview.md).
