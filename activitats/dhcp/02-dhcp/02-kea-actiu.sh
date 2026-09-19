#!/bin/bash
# TITLE: El servei Kea DHCP està en marxa
# DESCRIPTION: Comprova que la unitat kea-dhcp4-server.service està activa.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

cal_ordre systemctl

servei="kea-dhcp4-server.service"

if systemctl is-active --quiet "$servei"; then
    correcte "$servei està actiu."
fi

estat="$(systemctl is-active "$servei" 2>/dev/null)"
falla "$servei no està actiu; l'estat actual és '${estat:-desconegut}'."
