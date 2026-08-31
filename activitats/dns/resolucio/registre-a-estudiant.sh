#!/bin/bash
# TITLE: El registre A de l'estudiant és correcte
# DESCRIPTION: Comprova que host{N}.lab.local resol a l'adreça 192.168.10.{N}.

if [[ -z "${1:-}" ]]; then
    echo "Falta el número d'estudiant."
    exit 2
fi
student_number="$1"
expected_ip="192.168.10.${student_number}"
hostname="host${student_number}.lab.local"

if ! command -v dig >/dev/null 2>&1; then
    echo "L'ordre dig no està instal·lada."
    exit 2
fi

actual_ip="$(dig +short A "$hostname" 2>/dev/null | tail -n1)"

if [[ "$actual_ip" == "$expected_ip" ]]; then
    echo "$hostname resol a l'adreça esperada $expected_ip."
    exit 0
fi

echo "$hostname hauria de resoldre a $expected_ip, però s'ha obtingut '${actual_ip:-cap resposta}'."
exit 1
