#!/bin/bash
# TITLE: Existeix la subxarxa 192.168.{N}.0/24
# DESCRIPTION: Comprova que Kea té definida la subxarxa de la interfície eth2, 192.168.{N}.0/24, on {N} és el número d'estudiant.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="192.168.${N}.0/24"

if [[ -n "$(subxarxa "$prefix")" ]]; then
    correcte "Kea té definida la subxarxa $prefix."
fi

falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."
