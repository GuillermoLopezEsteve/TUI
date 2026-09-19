#!/bin/bash
# TITLE: La subxarxa d'eth2 anuncia el DNS 8.8.8.8
# DESCRIPTION: Comprova que l'opció domain-name-servers de la subxarxa 192.168.{N}.0/24 inclou l'adreça 8.8.8.8.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="192.168.${N}.0/24"
esperat="8.8.8.8"

[[ -n "$(subxarxa "$prefix")" ]] ||
    falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."

valor="$(opcio_subxarxa "$prefix" domain-name-servers)"

[[ -n "$valor" ]] ||
    falla "La subxarxa $prefix no té definida l'opció domain-name-servers; s'esperava $esperat."

if conte_valor "$valor" "$esperat"; then
    correcte "La subxarxa $prefix anuncia el DNS $esperat."
fi

falla "S'esperava el servidor DNS $esperat a la subxarxa $prefix, però l'opció domain-name-servers val '$valor'."
