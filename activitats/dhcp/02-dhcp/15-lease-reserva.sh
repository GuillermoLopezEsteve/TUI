#!/bin/bash
# TITLE: Hi ha una reserva d'eth1 en ús
# DESCRIPTION: Comprova que alguna de les adreces reservades, 10.50.{N}.10 o 10.50.{N}.15, té una concessió vigent.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
cal_ordre curl
cal_ordre jq
carrega_leases

reservades=("10.50.${N}.10" "10.50.${N}.15")

for adreca in "${reservades[@]}"; do
    if lease_activa "$adreca"; then
        correcte "L'adreça reservada $adreca té una concessió vigent."
    fi
done

falla "Cap de les adreces reservades (${reservades[*]}) té una concessió vigent. Arrenca el client amb l'adreça MAC reservada perquè agafi la seva IP."
