#!/bin/bash
# TITLE: La subxarxa d'eth1 anuncia el DNS 1.1.1.1
# DESCRIPTION: Comprova que l'opció domain-name-servers de la subxarxa 10.50.{N}.0/24 inclou l'adreça 1.1.1.1.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="10.50.${N}.0/24"
esperat="1.1.1.1"

[[ -n "$(subxarxa "$prefix")" ]] ||
    falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."

valor="$(opcio_subxarxa "$prefix" domain-name-servers)"

[[ -n "$valor" ]] ||
    falla "La subxarxa $prefix no té definida l'opció domain-name-servers; s'esperava $esperat."

if conte_valor "$valor" "$esperat"; then
    correcte "La subxarxa $prefix anuncia el DNS $esperat."
fi

falla "S'esperava el servidor DNS $esperat a la subxarxa $prefix, però l'opció domain-name-servers val '$valor'."
