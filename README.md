# LabCheck (smx2-checker)

A terminal app for SMX2 lab activities: it runs instructor-authored checks against your
machine (DHCP, DNS, etc.) and tells you, per check, what's correct and what isn't. It doesn't
configure anything for you — it just tells you where you stand.

Requires Linux and a terminal. All in-app text is in Catalan.

## 1. Install everything

Paste this whole block into a terminal. It installs Go 1.25 and git if they're missing,
downloads the code, and builds and installs `smx2-checker`:

```bash
GO_VERSION=1.25.0
curl -LO "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
rm "go${GO_VERSION}.linux-amd64.tar.gz"
grep -qxF 'export PATH="/usr/local/go/bin:$PATH"' ~/.bashrc || echo 'export PATH="/usr/local/go/bin:$PATH"' >> ~/.bashrc
export PATH="/usr/local/go/bin:$PATH"

sudo apt-get update -y
sudo apt-get install -y git

grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"

if [ -d TUI ]; then
    (cd TUI && git pull)
else
    git clone https://github.com/GuillermoLopezEsteve/TUI.git
fi
cd TUI
make install
cd ..

echo "Ara ja pots executar smx2-checker"
```

It's safe to run more than once: if `TUI/` already exists it just `git pull`s the latest
version instead of re-cloning, and it won't add duplicate lines to `~/.bashrc`. Re-run it any
time to update — `make install` always rebuilds first, so this picks up both code and
activity changes. `sudo` is used only for installing Go system-wide and for `apt-get`; it may
prompt for your password.

`export`s only apply to the current shell, so `smx2-checker` works immediately in the
terminal you ran this in. For every other terminal, either open a new one or run
`source ~/.bashrc` once.

## 2. Run it

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

Just re-run the block from step 1 — it pulls the latest code and reinstalls.

## Uninstalling

From inside the `TUI` folder:

```bash
make uninstall
```

## More detail

The full activity format and runner design are documented under
[`requirments/`](./requirments/00-overview.md).
