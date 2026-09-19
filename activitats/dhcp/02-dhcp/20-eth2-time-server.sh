#!/bin/bash
# TITLE: La subxarxa d'eth2 anuncia el servidor horari 130.206.3.166
# DESCRIPTION: Comprova que l'opció time-servers de la subxarxa 192.168.{N}.0/24 inclou l'adreça 130.206.3.166.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

llegeix_numero "${1:-}"
carrega_config_kea

prefix="192.168.${N}.0/24"
esperat="130.206.3.166"

[[ -n "$(subxarxa "$prefix")" ]] ||
    falla "Kea no té cap subxarxa $prefix. Les subxarxes definides són: $(llista_subxarxes)."

valor="$(opcio_subxarxa "$prefix" time-servers)"

if [[ -n "$valor" ]] && conte_valor "$valor" "$esperat"; then
    correcte "La subxarxa $prefix anuncia el servidor horari $esperat."
fi

if [[ -z "$valor" ]]; then
    # Confondre "Time Server" (opció 4) amb "NTP Servers" (opció 42) és un
    # error habitual, per això el missatge ho diu explícitament.
    alternativa="$(opcio_subxarxa "$prefix" ntp-servers)"
    if [[ -n "$alternativa" ]]; then
        falla "La subxarxa $prefix no té l'opció time-servers, sinó ntp-servers amb el valor '$alternativa'. El Time Server és l'opció DHCP 4, time-servers."
    fi
    falla "La subxarxa $prefix no té definida l'opció time-servers; s'esperava $esperat."
fi

falla "S'esperava el servidor horari $esperat a la subxarxa $prefix, però l'opció time-servers val '$valor'."
