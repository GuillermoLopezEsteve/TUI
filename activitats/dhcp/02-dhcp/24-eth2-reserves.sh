#!/bin/bash
# TITLE: La subxarxa d'eth2 reserva quatre adreces
# DESCRIPTION: Comprova que la subxarxa 192.168.{N}.0/24 té una reserva per a cadascuna de les adreces 192.168.{N}.10 a 192.168.{N}.13.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="192.168.${N}.0/24"
esperades=("192.168.${N}.10" "192.168.${N}.11" "192.168.${N}.12" "192.168.${N}.13")

[[ -n "$(subxarxa "$prefix")" ]] ||
    falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."

reservades="$(reserves_subxarxa "$prefix")"

falten=()
for adreca in "${esperades[@]}"; do
    grep -Fxq "$adreca" <<<"$reservades" || falten+=("$adreca")
done

if (( ${#falten[@]} == 0 )); then
    correcte "La subxarxa $prefix reserva les quatre adreces ${esperades[*]}."
fi

falla "Falten reserves a la subxarxa $prefix: ${falten[*]}. Les adreces reservades ara són: $(en_una_linia <<<"$reservades" | sed 's/^$/cap/')."
