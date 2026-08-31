#!/bin/bash
# TITLE: Hi ha una regla d'accés definida
# DESCRIPTION: Comprova que squid.conf conté almenys una línia "http_access allow".

config="/etc/squid/squid.conf"

if [[ ! -r "$config" ]]; then
    echo "$config no existeix o no es pot llegir."
    exit 2
fi

if grep -Eq '^[[:space:]]*http_access[[:space:]]+allow' "$config"; then
    echo "$config conté una regla 'http_access allow'."
    exit 0
fi

echo "$config no conté cap regla 'http_access allow'."
exit 1
