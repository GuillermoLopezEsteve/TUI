#!/bin/bash
# TITLE: El fitxer personalitzat de l'estudiant existeix
# DESCRIPTION: Comprova que existeix un fitxer test-file-{N} al directori de l'usuari.

if [[ -z "${1:-}" ]]; then
    echo "Falta el número d'estudiant."
    exit 2
fi
student_number="$1"
expected_file="$HOME/test-file-${student_number}"

if [[ -f "$expected_file" ]]; then
    echo "S'ha trobat $expected_file."
    exit 0
fi

echo "No s'ha trobat $expected_file. Crea'l per superar aquesta prova."
exit 1
