#!/bin/bash
# TITLE: L'usuari FTP de l'estudiant existeix
# DESCRIPTION: Comprova que l'usuari ftp{N} existeix al sistema.

if [[ -z "${1:-}" ]]; then
    echo "Falta el número d'estudiant."
    exit 2
fi
student_number="$1"
expected_user="ftp${student_number}"

if getent passwd "$expected_user" >/dev/null 2>&1; then
    echo "L'usuari $expected_user existeix."
    exit 0
fi

echo "No s'ha trobat l'usuari $expected_user."
exit 1
