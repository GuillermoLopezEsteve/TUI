#!/bin/bash
# TITLE: L'adreça d'eth1 és de la xarxa 10.50.{N}.0/24
# DESCRIPTION: Comprova que eth1 té una adreça IPv4 dins de la xarxa 10.50.{N}.0/24, on {N} és el número d'estudiant.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
cal_ordre ip

interficie="eth1"
xarxa="10.50.${N}.0"

ip -o link show dev "$interficie" >/dev/null 2>&1 ||
    falla "No existeix la interfície $interficie."

adreces="$(adreces_ipv4 "$interficie")"
[[ -n "$adreces" ]] ||
    falla "$interficie no té cap adreça IPv4; s'esperava una adreça de la xarxa ${xarxa}/24."

while IFS= read -r adreca; do
    if mateixa_xarxa_24 "$adreca" "$xarxa"; then
        correcte "$interficie té l'adreça $adreca, dins de la xarxa ${xarxa}/24."
    fi
done <<<"$adreces"

falla "Cap adreça de $interficie ($(en_una_linia <<<"$adreces")) pertany a la xarxa ${xarxa}/24."
