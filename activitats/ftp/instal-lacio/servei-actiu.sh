#!/bin/bash
# TITLE: El servei vsftpd està actiu
# DESCRIPTION: Comprova que el servei vsftpd està en execució.

if ! command -v systemctl >/dev/null 2>&1; then
    echo "L'ordre systemctl no està disponible en aquest sistema."
    exit 2
fi

if systemctl is-active --quiet vsftpd; then
    echo "El servei vsftpd està actiu."
    exit 0
fi

echo "El servei vsftpd no està actiu."
exit 1
