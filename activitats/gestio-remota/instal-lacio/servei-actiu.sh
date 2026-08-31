#!/bin/bash
# TITLE: El servei SSH està actiu
# DESCRIPTION: Comprova que el servei ssh (sshd) està en execució.

if ! command -v systemctl >/dev/null 2>&1; then
    echo "L'ordre systemctl no està disponible en aquest sistema."
    exit 2
fi

if systemctl is-active --quiet ssh || systemctl is-active --quiet sshd; then
    echo "El servei SSH està actiu."
    exit 0
fi

echo "El servei SSH no està actiu."
exit 1
