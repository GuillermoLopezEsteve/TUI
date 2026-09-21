#!/usr/bin/env bash
# Installs Go 1.27 and git if needed, then downloads (or updates), builds
# and installs smx2-checker. Safe to run more than once.
set -euo pipefail

if [ "$EUID" -eq 0 ]; then
    echo "No correr amb sudo, només bash install.sh"
    exit 2
fi

sudo apt-get update -y
sudo apt-get install -y git tree net-tools jq make curl

GO_VERSION=1.27.0

curl -LO "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
rm "go${GO_VERSION}.linux-amd64.tar.gz"
grep -qxF 'export PATH="/usr/local/go/bin:$PATH"' ~/.bashrc || echo 'export PATH="/usr/local/go/bin:$PATH"' >> ~/.bashrc
export PATH="/usr/local/go/bin:$PATH"
echo "GO ${GO_VERSION} installed"

grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
export PATH="$HOME/.local/bin:$PATH"

echo "Installing TUI"
if [ -d TUI ]; then
    (cd TUI && git pull)
else
    echo "Downloading"
    git clone https://github.com/GuillermoLopezEsteve/TUI.git
fi
cd TUI
make install
cd ..

echo "Ara ja pots executar smx2-checker, si no funciona prova a fer source ~/.bashrc"
