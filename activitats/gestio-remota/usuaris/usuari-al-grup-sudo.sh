#!/bin/bash
# TITLE: L'usuari administrador pertany al grup sudo
# DESCRIPTION: Comprova que admin{N} pertany al grup sudo.

if [[ -z "${1:-}" ]]; then
    echo "Falta el número d'estudiant."
    exit 2
fi
student_number="$1"
expected_user="admin${student_number}"

if ! id "$expected_user" >/dev/null 2>&1; then
    echo "L'usuari $expected_user no existeix."
    exit 1
fi

if id -nG "$expected_user" 2>/dev/null | tr ' ' '\n' | grep -Fxq sudo; then
    echo "L'usuari $expected_user pertany al grup sudo."
    exit 0
fi

echo "L'usuari $expected_user no pertany al grup sudo."
exit 1
