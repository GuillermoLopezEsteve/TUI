#!/bin/bash
# TITLE: El client ha rebut l'adreça IP de l'estudiant
# DESCRIPTION: Comprova que alguna interfície té l'adreça 192.168.10.{N}.

if [[ -z "${1:-}" ]]; then
    echo "Falta el número d'estudiant."
    exit 2
fi
student_number="$1"
expected_ip="192.168.10.${student_number}"

if ip -4 -o addr show 2>/dev/null | grep -q "$expected_ip/"; then
    echo "S'ha trobat l'adreça $expected_ip."
    exit 0
fi

echo "No s'ha trobat cap interfície amb l'adreça $expected_ip."
exit 1
