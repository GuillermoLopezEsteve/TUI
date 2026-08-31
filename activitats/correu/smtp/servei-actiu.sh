#!/bin/bash
# TITLE: El servei Postfix està actiu
# DESCRIPTION: Comprova que el servei postfix està en execució.

if ! command -v systemctl >/dev/null 2>&1; then
    echo "L'ordre systemctl no està disponible en aquest sistema."
    exit 2
fi

if systemctl is-active --quiet postfix; then
    echo "El servei postfix està actiu."
    exit 0
fi

echo "El servei postfix no està actiu."
exit 1
