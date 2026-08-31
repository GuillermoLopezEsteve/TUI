#!/bin/bash
# TITLE: El fitxer de concessions existeix
# DESCRIPTION: Comprova que /var/lib/dhcp/dhcpd.leases existeix.

if [[ -e /var/lib/dhcp/dhcpd.leases ]]; then
    echo "El fitxer de concessions existeix."
    exit 0
fi

echo "No s'ha trobat /var/lib/dhcp/dhcpd.leases."
exit 1
