#!/bin/bash
# TITLE: El servei Squid està actiu
# DESCRIPTION: Comprova que el servei squid està en execució.

if ! command -v systemctl >/dev/null 2>&1; then
    echo "L'ordre systemctl no està disponible en aquest sistema."
    exit 2
fi

if systemctl is-active --quiet squid; then
    echo "El servei squid està actiu."
    exit 0
fi

echo "El servei squid no està actiu."
exit 1
