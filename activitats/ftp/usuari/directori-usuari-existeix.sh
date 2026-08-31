#!/bin/bash
# TITLE: El directori de l'usuari FTP existeix
# DESCRIPTION: Comprova que existeix el directori d'inici de l'usuari ftp{N}.

if [[ -z "${1:-}" ]]; then
    echo "Falta el número d'estudiant."
    exit 2
fi
student_number="$1"
expected_user="ftp${student_number}"
home_dir="$(getent passwd "$expected_user" 2>/dev/null | cut -d: -f6)"

if [[ -n "$home_dir" && -d "$home_dir" ]]; then
    echo "El directori d'inici de $expected_user ($home_dir) existeix."
    exit 0
fi

echo "No s'ha trobat el directori d'inici de l'usuari $expected_user."
exit 1
