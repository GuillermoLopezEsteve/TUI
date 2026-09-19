#!/bin/bash
# TITLE: La subxarxa d'eth2 apunta al servidor PXE 192.168.{N}.6
# DESCRIPTION: Comprova que el paràmetre next-server de la subxarxa 192.168.{N}.0/24 val 192.168.{N}.6.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="192.168.${N}.0/24"
esperat="192.168.${N}.6"

[[ -n "$(subxarxa "$prefix")" ]] ||
    falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."

valor="$(parametre_subxarxa "$prefix" next-server)"

if [[ "$valor" == "$esperat" ]]; then
    correcte "La subxarxa $prefix apunta al servidor d'arrencada $esperat."
fi

# Kea deixa next-server a 0.0.0.0 mentre no se li assigna cap valor.
if [[ -z "$valor" || "$valor" == "0.0.0.0" ]]; then
    falla "La subxarxa $prefix no té cap next-server configurat; s'esperava $esperat."
fi

falla "S'esperava el next-server $esperat a la subxarxa $prefix, però val '$valor'."
