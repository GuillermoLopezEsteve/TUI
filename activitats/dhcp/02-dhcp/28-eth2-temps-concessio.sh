#!/bin/bash
# TITLE: El temps de concessió d'eth2 és de 5 minuts
# DESCRIPTION: Comprova que el valid-lifetime efectiu de la subxarxa 192.168.{N}.0/24 és de 300 segons.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="192.168.${N}.0/24"
esperat=300

[[ -n "$(subxarxa "$prefix")" ]] ||
    falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."

valor="$(parametre_subxarxa "$prefix" valid-lifetime)"

[[ "$valor" =~ ^[0-9]+$ ]] ||
    falla "No s'ha pogut llegir el valid-lifetime de la subxarxa $prefix; s'esperaven $esperat segons."

if (( valor == esperat )); then
    correcte "El temps de concessió de $prefix és de $esperat segons (5 minuts)."
fi

falla "S'esperava un temps de concessió de $esperat segons (5 minuts) a la subxarxa $prefix, però el valid-lifetime és de $valor segons."
