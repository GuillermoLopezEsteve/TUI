#!/bin/bash
# TITLE: La subxarxa d'eth1 anuncia la passarel·la 10.50.{N}.1
# DESCRIPTION: Comprova que l'opció routers de la subxarxa 10.50.{N}.0/24 inclou l'adreça del router, 10.50.{N}.1.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="10.50.${N}.0/24"
esperat="10.50.${N}.1"

[[ -n "$(subxarxa "$prefix")" ]] ||
    falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."

valor="$(opcio_subxarxa "$prefix" routers)"

[[ -n "$valor" ]] ||
    falla "La subxarxa $prefix no té definida l'opció routers; s'esperava $esperat."

if conte_valor "$valor" "$esperat"; then
    correcte "La subxarxa $prefix anuncia la passarel·la $esperat."
fi

falla "S'esperava la passarel·la $esperat a la subxarxa $prefix, però l'opció routers val '$valor'."
