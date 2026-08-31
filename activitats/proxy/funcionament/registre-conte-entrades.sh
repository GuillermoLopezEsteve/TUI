#!/bin/bash
# TITLE: El registre conté entrades
# DESCRIPTION: Comprova que /var/log/squid/access.log no està buit.

log="/var/log/squid/access.log"

if [[ ! -r "$log" ]]; then
    echo "$log no existeix o no es pot llegir."
    exit 2
fi

if [[ -s "$log" ]]; then
    echo "$log conté entrades registrades."
    exit 0
fi

echo "$log existeix però està buit. Genera trànsit a través del proxy."
exit 1
