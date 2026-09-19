#!/bin/bash
# TITLE: Hi ha una concessió dinàmica al rang d'eth1
# DESCRIPTION: Comprova que algun client ha rebut una adreça vigent del pool 10.50.{N}.100-150.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
cal_ordre curl
cal_ordre jq
carrega_leases

inici="10.50.${N}.100"
final="10.50.${N}.150"

trobades="$(leases_actives_al_rang "$inici" "$final")"

if [[ -n "$trobades" ]]; then
    correcte "Hi ha concessions dinàmiques vigents al rang $inici - $final: $(en_una_linia <<<"$trobades")."
fi

falla "No hi ha cap concessió vigent entre $inici i $final. Connecta un client a la xarxa d'eth1 perquè demani una adreça al servidor DHCP."
