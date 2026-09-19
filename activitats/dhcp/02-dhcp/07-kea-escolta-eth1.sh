#!/bin/bash
# TITLE: Kea escolta per la interfície eth1
# DESCRIPTION: Comprova que "interfaces-config" de Kea inclou eth1, de manera que el servidor atén peticions DHCP per aquesta interfície.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

carrega_config_kea

interficie="eth1"
llista="$(interficies_kea)"

# Una entrada pot ser "eth1", "eth1/10.50.N.2" o "*" (totes les interfícies).
while IFS= read -r entrada; do
    nom="${entrada%%/*}"
    if [[ "$nom" == "$interficie" || "$nom" == "*" ]]; then
        correcte "Kea escolta per $interficie (entrada '$entrada')."
    fi
done <<<"$llista"

falla "La llista interfaces-config de Kea no inclou $interficie; ara hi ha: $(en_una_linia <<<"$llista" | sed 's/^$/cap interfície/')."
