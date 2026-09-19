#!/bin/bash
# TITLE: La subxarxa d'eth2 anuncia el domini user{N}.lan
# DESCRIPTION: Comprova que l'opció domain-name de la subxarxa 192.168.{N}.0/24 val user{N}.lan, on {N} és el número d'estudiant.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="192.168.${N}.0/24"
esperat="user${N}.lan"

[[ -n "$(subxarxa "$prefix")" ]] ||
    falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."

valor="$(opcio_subxarxa "$prefix" domain-name)"

[[ -n "$valor" ]] ||
    falla "La subxarxa $prefix no té definida l'opció domain-name; s'esperava $esperat."

# Els noms de domini no distingeixen majúscules de minúscules.
if [[ "${valor,,}" == "${esperat,,}" ]]; then
    correcte "La subxarxa $prefix anuncia el domini $esperat."
fi

falla "S'esperava el domini $esperat a la subxarxa $prefix, però l'opció domain-name val '$valor'."
