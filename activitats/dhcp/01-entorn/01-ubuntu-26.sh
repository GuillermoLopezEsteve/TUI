#!/bin/bash
# TITLE: El sistema operatiu és Ubuntu 26
# DESCRIPTION: Comprova que /etc/os-release identifica la màquina com a Ubuntu de la versió 26.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

fitxer="/etc/os-release"
[[ -r "$fitxer" ]] || no_comprovable "$fitxer no existeix o no es pot llegir."

distribucio="$(grep -m1 '^ID=' "$fitxer" | cut -d= -f2- | tr -d '"')"
versio="$(grep -m1 '^VERSION_ID=' "$fitxer" | cut -d= -f2- | tr -d '"')"

if [[ "$distribucio" != "ubuntu" ]]; then
    falla "S'esperava la distribució Ubuntu, però $fitxer indica ID=${distribucio:-desconegut}."
fi

if [[ "${versio%%.*}" != "26" ]]; then
    falla "S'esperava Ubuntu 26, però la versió instal·lada és ${versio:-desconeguda}."
fi

correcte "El sistema és Ubuntu $versio."
