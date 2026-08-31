#!/bin/bash
# TITLE: El servei DHCP està actiu
# DESCRIPTION: Comprova que el servei isc-dhcp-server està en execució.

if ! command -v systemctl >/dev/null 2>&1; then
    echo "L'ordre systemctl no està disponible en aquest sistema."
    exit 2
fi

if systemctl is-active --quiet isc-dhcp-server; then
    echo "El servei isc-dhcp-server està actiu."
    exit 0
fi

state="$(systemctl is-active isc-dhcp-server 2>/dev/null || true)"
echo "El servei isc-dhcp-server no està actiu (estat: ${state:-desconegut})."
exit 1
