#!/bin/bash
# TITLE: L'adreça d'eth0 és de la xarxa 192.168.56.0/24
# DESCRIPTION: Comprova que eth0 té una adreça IPv4 dins de la xarxa 192.168.56.0/24.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

cal_ordre ip

interficie="eth0"
xarxa="192.168.56.0"

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
