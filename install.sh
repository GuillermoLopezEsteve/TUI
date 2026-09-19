#!/usr/bin/env bash
# Installs Go 1.27 and git if needed, then downloads (or updates), builds
# and installs smx2-checker. Safe to run more than once.
set -e

if [ "$UID" != "$EUID" ]; then
    echo "No correr com sudo, només bash install.sh"
    exit 2
fi
GO_VERSION=1.27.0

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

source "$HOME/.bashrc"
echo "Ara ja pots executar smx2-checker"
