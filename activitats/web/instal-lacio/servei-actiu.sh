#!/bin/bash
# TITLE: El servei Apache està actiu
# DESCRIPTION: Comprova que el servei apache2 està en execució.

if ! command -v systemctl >/dev/null 2>&1; then
    echo "L'ordre systemctl no està disponible en aquest sistema."
    exit 2
fi

if systemctl is-active --quiet apache2; then
    echo "El servei apache2 està actiu."
    exit 0
fi

echo "El servei apache2 no està actiu."
exit 1
