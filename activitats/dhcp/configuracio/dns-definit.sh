#!/bin/bash
# TITLE: El servidor DNS del client està definit
# DESCRIPTION: Comprova que dhcpd.conf defineix l'opció "option domain-name-servers".

config="/etc/dhcp/dhcpd.conf"

if [[ ! -r "$config" ]]; then
    echo "$config no existeix o no es pot llegir."
    exit 2
fi

if grep -Eq '^[[:space:]]*option[[:space:]]+domain-name-servers[[:space:]]' "$config"; then
    echo "$config defineix l'opció 'option domain-name-servers'."
    exit 0
fi

echo "$config no defineix l'opció 'option domain-name-servers'."
exit 1
