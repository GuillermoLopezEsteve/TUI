#!/bin/bash
# TITLE: La subxarxa d'eth1 té el rang 10.50.{N}.100-150
# DESCRIPTION: Comprova que la subxarxa 10.50.{N}.0/24 té un pool d'adreces que va de 10.50.{N}.100 a 10.50.{N}.150.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="10.50.${N}.0/24"
inici="10.50.${N}.100"
final="10.50.${N}.150"

[[ -n "$(subxarxa "$prefix")" ]] ||
    falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."

if te_pool "$prefix" "$inici" "$final"; then
    correcte "La subxarxa $prefix té el pool $inici - $final."
fi

falla "La subxarxa $prefix no té cap pool de $inici a $final. Els pools definits són: $(pools_subxarxa "$prefix" | en_una_linia | sed 's/^$/cap/')."
