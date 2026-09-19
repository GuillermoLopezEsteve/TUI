#!/bin/bash
# TITLE: La subxarxa d'eth1 reserva 10.50.{N}.10 i 10.50.{N}.15
# DESCRIPTION: Comprova que la subxarxa 10.50.{N}.0/24 té una reserva d'amfitrió per a cadascuna de les dues adreces.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="10.50.${N}.0/24"
esperades=("10.50.${N}.10" "10.50.${N}.15")

[[ -n "$(subxarxa "$prefix")" ]] ||
    falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."

reservades="$(reserves_subxarxa "$prefix")"

falten=()
for adreca in "${esperades[@]}"; do
    grep -Fxq "$adreca" <<<"$reservades" || falten+=("$adreca")
done

if (( ${#falten[@]} == 0 )); then
    correcte "La subxarxa $prefix reserva ${esperades[0]} i ${esperades[1]}."
fi

falla "Falten reserves a la subxarxa $prefix: ${falten[*]}. Les adreces reservades ara són: $(en_una_linia <<<"$reservades" | sed 's/^$/cap/')."
