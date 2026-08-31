#!/bin/bash
# TITLE: L'usuari té una clau SSH autoritzada
# DESCRIPTION: Comprova que existeix ~/.ssh/authorized_keys per a l'usuari admin{N}.

if [[ -z "${1:-}" ]]; then
    echo "Falta el número d'estudiant."
    exit 2
fi
student_number="$1"
expected_user="admin${student_number}"
home_dir="$(getent passwd "$expected_user" 2>/dev/null | cut -d: -f6)"

if [[ -n "$home_dir" && -f "${home_dir}/.ssh/authorized_keys" ]]; then
    echo "S'ha trobat ${home_dir}/.ssh/authorized_keys."
    exit 0
fi

echo "No s'ha trobat cap fitxer authorized_keys per a l'usuari $expected_user."
exit 1
