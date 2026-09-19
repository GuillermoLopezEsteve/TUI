#!/bin/bash
# TITLE: Existeix la interfície eth0
# DESCRIPTION: Comprova que la màquina té una interfície de xarxa anomenada eth0.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

cal_ordre ip

interficie="eth0"

if ! ip -o link show dev "$interficie" >/dev/null 2>&1; then
    existents="$(ip -o link show 2>/dev/null | awk '{n=$2; sub(/:$/,"",n); sub(/@.*/,"",n); print n}' | en_una_linia)"
    falla "No existeix cap interfície anomenada $interficie. Les interfícies d'aquesta màquina són: ${existents:-cap}."
fi

correcte "La interfície $interficie existeix."
