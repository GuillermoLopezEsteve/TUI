#!/bin/bash
# TITLE: La subxarxa d'eth2 anuncia els dominis de cerca
# DESCRIPTION: Comprova que l'opció domain-search de la subxarxa 192.168.{N}.0/24 inclou user{N}.lan i smx2.gabriela.lan.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="192.168.${N}.0/24"
esperats=("user${N}.lan" "smx2.gabriela.lan")

[[ -n "$(subxarxa "$prefix")" ]] ||
    falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."

valor="$(opcio_subxarxa "$prefix" domain-search)"

[[ -n "$valor" ]] ||
    falla "La subxarxa $prefix no té definida l'opció domain-search; s'esperaven ${esperats[*]}."

falten=()
for domini in "${esperats[@]}"; do
    conte_valor "${valor,,}" "$domini" || falten+=("$domini")
done

if (( ${#falten[@]} == 0 )); then
    correcte "La subxarxa $prefix anuncia els dominis de cerca ${esperats[*]}."
fi

falla "Falten dominis a l'opció domain-search de la subxarxa $prefix: ${falten[*]}. El valor actual és '$valor'."
