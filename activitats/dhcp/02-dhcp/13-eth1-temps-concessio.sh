#!/bin/bash
# TITLE: El temps de concessió d'eth1 és d'una hora
# DESCRIPTION: Comprova que el valid-lifetime efectiu de la subxarxa 10.50.{N}.0/24 és de 3600 segons.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="10.50.${N}.0/24"
esperat=3600

[[ -n "$(subxarxa "$prefix")" ]] ||
    falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."

valor="$(parametre_subxarxa "$prefix" valid-lifetime)"

[[ "$valor" =~ ^[0-9]+$ ]] ||
    falla "No s'ha pogut llegir el valid-lifetime de la subxarxa $prefix; s'esperaven $esperat segons."

if (( valor == esperat )); then
    correcte "El temps de concessió de $prefix és de $esperat segons (1 hora)."
fi

falla "S'esperava un temps de concessió de $esperat segons (1 hora) a la subxarxa $prefix, però el valid-lifetime és de $valor segons."
