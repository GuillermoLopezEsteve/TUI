#!/bin/bash
# TITLE: El servei Dovecot està actiu
# DESCRIPTION: Comprova que el servei dovecot està en execució.

if ! command -v systemctl >/dev/null 2>&1; then
    echo "L'ordre systemctl no està disponible en aquest sistema."
    exit 2
fi

if systemctl is-active --quiet dovecot; then
    echo "El servei dovecot està actiu."
    exit 0
fi

echo "El servei dovecot no està actiu."
exit 1
