#!/bin/bash
# TITLE: La zona directa està definida
# DESCRIPTION: Comprova que named.conf.local conté una declaració "zone" de tipus master.

config="/etc/bind/named.conf.local"

if [[ ! -r "$config" ]]; then
    echo "$config no existeix o no es pot llegir."
    exit 2
fi

if grep -Eq '^[[:space:]]*zone[[:space:]]+"[^"]+"' "$config"; then
    echo "$config defineix almenys una zona."
    exit 0
fi

echo "$config no conté cap declaració 'zone'."
exit 1
