#!/bin/bash
# TITLE: La zona inversa està definida
# DESCRIPTION: Comprova que named.conf.local conté una zona in-addr.arpa per a la resolució inversa.

config="/etc/bind/named.conf.local"

if [[ ! -r "$config" ]]; then
    echo "$config no existeix o no es pot llegir."
    exit 2
fi

if grep -Eq 'in-addr\.arpa' "$config"; then
    echo "$config defineix una zona in-addr.arpa."
    exit 0
fi

echo "$config no conté cap zona in-addr.arpa (resolució inversa)."
exit 1
