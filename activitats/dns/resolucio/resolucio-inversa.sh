#!/bin/bash
# TITLE: La resolució inversa de l'estudiant és correcta
# DESCRIPTION: Comprova que 192.168.10.{N} resol al nom host{N}.lab.local.

if [[ -z "${1:-}" ]]; then
    echo "Falta el número d'estudiant."
    exit 2
fi
student_number="$1"
expected_ip="192.168.10.${student_number}"
expected_name="host${student_number}.lab.local."

if ! command -v dig >/dev/null 2>&1; then
    echo "L'ordre dig no està instal·lada."
    exit 2
fi

actual_name="$(dig +short -x "$expected_ip" 2>/dev/null | tail -n1)"

if [[ "$actual_name" == "$expected_name" ]]; then
    echo "$expected_ip resol correctament a $expected_name"
    exit 0
fi

echo "$expected_ip hauria de resoldre a $expected_name, però s'ha obtingut '${actual_name:-cap resposta}'."
exit 1
