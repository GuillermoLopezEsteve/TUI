#!/bin/bash
# TITLE: Es pot fer ping a google.com
# DESCRIPTION: Comprova que el nom google.com es resol i que l'adreça obtinguda respon al ping.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

cal_ordre ping

desti="google.com"

# Es distingeix un problema de resolució de noms d'un problema de connectivitat,
# perquè la solució de cada cas és diferent.
if ! getent ahostsv4 "$desti" >/dev/null 2>&1; then
    falla "El nom $desti no es resol. Comprova el servidor DNS configurat a la màquina."
fi

if ping -c 2 -W 3 -n "$desti" >/dev/null 2>&1; then
    correcte "$desti es resol i respon al ping."
fi

falla "$desti es resol correctament, però no respon al ping. Comprova la sortida a Internet de la màquina."
