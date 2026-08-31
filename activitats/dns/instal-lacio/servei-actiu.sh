#!/bin/bash
# TITLE: El servei DNS està actiu
# DESCRIPTION: Comprova que el servei bind9 (named) està en execució.

if ! command -v systemctl >/dev/null 2>&1; then
    echo "L'ordre systemctl no està disponible en aquest sistema."
    exit 2
fi

if systemctl is-active --quiet bind9 || systemctl is-active --quiet named; then
    echo "El servei DNS està actiu."
    exit 0
fi

echo "El servei DNS (bind9/named) no està actiu."
exit 1
