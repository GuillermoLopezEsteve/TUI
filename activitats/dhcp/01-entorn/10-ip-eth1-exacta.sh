#!/bin/bash
# TITLE: L'adreça d'eth1 és 10.50.{N}.2
# DESCRIPTION: Comprova que eth1 té configurada exactament l'adreça IPv4 10.50.{N}.2, on {N} és el número d'estudiant.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
cal_ordre ip

interficie="eth1"
esperada="10.50.${N}.2"

ip -o link show dev "$interficie" >/dev/null 2>&1 ||
    falla "No existeix la interfície $interficie."

adreces="$(adreces_ipv4 "$interficie")"

if grep -Fxq "$esperada" <<<"$adreces"; then
    correcte "$interficie té l'adreça $esperada."
fi

falla "S'esperava l'adreça $esperada a $interficie, però hi ha: $(en_una_linia <<<"$adreces" | sed 's/^$/cap adreça IPv4/')."
