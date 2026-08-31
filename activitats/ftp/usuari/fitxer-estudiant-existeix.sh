#!/bin/bash
# TITLE: El fitxer personalitzat de l'estudiant existeix
# DESCRIPTION: Comprova que test-file-{N} existeix dins del directori de l'usuari ftp{N}.

if [[ -z "${1:-}" ]]; then
    echo "Falta el número d'estudiant."
    exit 2
fi
student_number="$1"
expected_user="ftp${student_number}"
home_dir="$(getent passwd "$expected_user" 2>/dev/null | cut -d: -f6)"
expected_file="${home_dir}/test-file-${student_number}"

if [[ -n "$home_dir" && -f "$expected_file" ]]; then
    echo "S'ha trobat $expected_file."
    exit 0
fi

echo "No s'ha trobat $expected_file. Puja'l per superar aquesta prova."
exit 1
