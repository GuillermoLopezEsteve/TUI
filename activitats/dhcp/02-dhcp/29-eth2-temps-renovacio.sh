#!/bin/bash
# TITLE: El temps de renovació d'eth2 és de 2 minuts
# DESCRIPTION: Comprova que el renew-timer efectiu de la subxarxa 192.168.{N}.0/24 és de 120 segons.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="192.168.${N}.0/24"
esperat=120

[[ -n "$(subxarxa "$prefix")" ]] ||
    falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."

valor="$(parametre_subxarxa "$prefix" renew-timer)"

[[ "$valor" =~ ^[0-9]+$ ]] ||
    falla "No s'ha pogut llegir el renew-timer de la subxarxa $prefix; s'esperaven $esperat segons."

if (( valor == esperat )); then
    correcte "El temps de renovació de $prefix és de $esperat segons (2 minuts)."
fi

falla "S'esperava un temps de renovació de $esperat segons (2 minuts) a la subxarxa $prefix, però el renew-timer és de $valor segons."
