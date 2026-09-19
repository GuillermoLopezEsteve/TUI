#!/bin/bash
# TITLE: Kea DHCP està instal·lat
# DESCRIPTION: Comprova que el paquet kea-dhcp4-server està instal·lat i que el binari kea-dhcp4 hi és.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

if command -v kea-dhcp4 >/dev/null 2>&1 || [[ -x /usr/sbin/kea-dhcp4 ]]; then
    correcte "Kea DHCP està instal·lat."
fi

if [[ "$(dpkg-query -W -f='${Status}' kea-dhcp4-server 2>/dev/null)" == "install ok installed" ]]; then
    correcte "El paquet kea-dhcp4-server està instal·lat."
fi

falla "No s'ha trobat el binari kea-dhcp4 ni el paquet kea-dhcp4-server instal·lat."
