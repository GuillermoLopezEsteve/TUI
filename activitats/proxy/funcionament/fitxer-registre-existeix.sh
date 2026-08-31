#!/bin/bash
# TITLE: El fitxer de registre existeix
# DESCRIPTION: Comprova que /var/log/squid/access.log existeix.

if [[ -e /var/log/squid/access.log ]]; then
    echo "El fitxer de registre existeix."
    exit 0
fi

echo "No s'ha trobat /var/log/squid/access.log."
exit 1
