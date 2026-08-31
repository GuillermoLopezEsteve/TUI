#!/bin/bash
# TITLE: Hi ha una ACL per a la xarxa de l'aula
# DESCRIPTION: Comprova que squid.conf defineix una ACL amb la xarxa 192.168.10.0/24.

config="/etc/squid/squid.conf"

if [[ ! -r "$config" ]]; then
    echo "$config no existeix o no es pot llegir."
    exit 2
fi

if grep -Eq '^[[:space:]]*acl[[:space:]]+\S+[[:space:]]+src[[:space:]]+192\.168\.10\.0/24' "$config"; then
    echo "$config defineix una ACL per a la xarxa 192.168.10.0/24."
    exit 0
fi

echo "$config no defineix cap ACL per a la xarxa 192.168.10.0/24."
exit 1
