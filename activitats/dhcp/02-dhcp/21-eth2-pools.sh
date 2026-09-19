#!/bin/bash
# TITLE: La subxarxa d'eth2 té els dos rangs d'adreces
# DESCRIPTION: Comprova que la subxarxa 192.168.{N}.0/24 té els pools 192.168.{N}.100-120 i 192.168.{N}.200-240.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="192.168.${N}.0/24"

[[ -n "$(subxarxa "$prefix")" ]] ||
    falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."

falten=()
te_pool "$prefix" "192.168.${N}.100" "192.168.${N}.120" || falten+=("192.168.${N}.100-192.168.${N}.120")
te_pool "$prefix" "192.168.${N}.200" "192.168.${N}.240" || falten+=("192.168.${N}.200-192.168.${N}.240")

if (( ${#falten[@]} == 0 )); then
    correcte "La subxarxa $prefix té els dos pools demanats."
fi

falla "Falten pools a la subxarxa $prefix: ${falten[*]}. Els pools definits són: $(pools_subxarxa "$prefix" | en_una_linia | sed 's/^$/cap/')."
