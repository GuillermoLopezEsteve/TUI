#!/bin/bash
# TITLE: La subxarxa d'eth2 arrenca el fitxer pxelinux.0
# DESCRIPTION: Comprova que la subxarxa 192.168.{N}.0/24 anuncia pxelinux.0 com a fitxer d'arrencada PXE.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="192.168.${N}.0/24"
esperat="pxelinux.0"

[[ -n "$(subxarxa "$prefix")" ]] ||
    falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."

# El nom del fitxer es pot donar com a paràmetre boot-file-name o bé com a
# opció DHCP 67, que també es diu boot-file-name; es consideren tots dos casos.
valor="$(parametre_subxarxa "$prefix" boot-file-name)"
if [[ -z "$valor" ]]; then
    valor="$(opcio_subxarxa "$prefix" boot-file-name)"
fi

if [[ "$valor" == "$esperat" ]]; then
    correcte "La subxarxa $prefix anuncia el fitxer d'arrencada $esperat."
fi

[[ -n "$valor" ]] ||
    falla "La subxarxa $prefix no té cap boot-file-name configurat; s'esperava $esperat."

falla "S'esperava el fitxer d'arrencada $esperat a la subxarxa $prefix, però boot-file-name val '$valor'."
