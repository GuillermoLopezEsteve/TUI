#!/bin/bash
# TITLE: El fitxer de configuració existeix
# DESCRIPTION: Comprova que /etc/dhcp/dhcpd.conf existeix i es pot llegir.

if [[ -r /etc/dhcp/dhcpd.conf ]]; then
    echo "/etc/dhcp/dhcpd.conf existeix i es pot llegir."
    exit 0
fi

echo "/etc/dhcp/dhcpd.conf no existeix o no es pot llegir."
exit 1
