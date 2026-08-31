#!/bin/bash
# TITLE: El paquet del servidor DHCP està instal·lat
# DESCRIPTION: Comprova que isc-dhcp-server (o un dimoni dhcpd equivalent) està instal·lat.

if dpkg -s isc-dhcp-server >/dev/null 2>&1 || command -v dhcpd >/dev/null 2>&1; then
    echo "El servidor DHCP està instal·lat."
    exit 0
fi

echo "No s'ha trobat cap servidor DHCP instal·lat (isc-dhcp-server)."
exit 1
