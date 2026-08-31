#!/bin/bash
# TITLE: L'opció de router (gateway) està definida
# DESCRIPTION: Comprova que dhcpd.conf defineix l'opció "option routers".

config="/etc/dhcp/dhcpd.conf"

if [[ ! -r "$config" ]]; then
    echo "$config no existeix o no es pot llegir."
    exit 2
fi

if grep -Eq '^[[:space:]]*option[[:space:]]+routers[[:space:]]' "$config"; then
    echo "$config defineix l'opció 'option routers'."
    exit 0
fi

echo "$config no defineix l'opció 'option routers'."
exit 1
