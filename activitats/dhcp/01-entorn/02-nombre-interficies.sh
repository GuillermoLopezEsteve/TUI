#!/bin/bash
# TITLE: La màquina té tres interfícies de xarxa
# DESCRIPTION: Comprova que "ip -o link show" llista 3 interfícies més la de loopback, és a dir 4 en total.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

cal_ordre ip

total="$(ip -o link show 2>/dev/null | wc -l)"

if (( total != 4 )); then
    noms="$(ip -o link show 2>/dev/null | awk '{n=$2; sub(/:$/,"",n); sub(/@.*/,"",n); print n}' | en_una_linia)"
    falla "S'esperaven 4 interfícies (3 de xarxa més loopback), però n'hi ha $total: ${noms:-cap}."
fi

correcte "Hi ha 4 interfícies: 3 de xarxa més la de loopback."
