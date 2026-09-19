#!/bin/bash
# TITLE: Les reserves d'eth2 tenen un nom d'amfitrió
# DESCRIPTION: Comprova que cadascuna de les reserves 192.168.{N}.10 a 192.168.{N}.13 té assignat un hostname.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="192.168.${N}.0/24"
esperades=("192.168.${N}.10" "192.168.${N}.11" "192.168.${N}.12" "192.168.${N}.13")

[[ -n "$(subxarxa "$prefix")" ]] ||
    falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."

sense_nom=()
assignats=()
for adreca in "${esperades[@]}"; do
    nom="$(hostname_reserva "$prefix" "$adreca")"
    if [[ -z "$nom" ]]; then
        sense_nom+=("$adreca")
    else
        assignats+=("$adreca=$nom")
    fi
done

if (( ${#sense_nom[@]} == 0 )); then
    correcte "Les quatre reserves tenen nom: ${assignats[*]}."
fi

falla "Aquestes reserves de $prefix no tenen cap hostname assignat: ${sense_nom[*]}."
