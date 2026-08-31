#!/bin/bash
# TITLE: Hi ha una subxarxa definida
# DESCRIPTION: Comprova que dhcpd.conf conté almenys una declaració "subnet".

config="/etc/dhcp/dhcpd.conf"

if [[ ! -r "$config" ]]; then
    echo "$config no existeix o no es pot llegir."
    exit 2
fi

if grep -Eq '^[[:space:]]*subnet[[:space:]]' "$config"; then
    echo "$config defineix almenys una subxarxa."
    exit 0
fi

echo "$config no conté cap declaració 'subnet'."
exit 1
