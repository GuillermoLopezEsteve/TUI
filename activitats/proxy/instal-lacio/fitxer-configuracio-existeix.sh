#!/bin/bash
# TITLE: El fitxer de configuració existeix
# DESCRIPTION: Comprova que /etc/squid/squid.conf existeix i es pot llegir.

if [[ -r /etc/squid/squid.conf ]]; then
    echo "/etc/squid/squid.conf existeix i es pot llegir."
    exit 0
fi

echo "/etc/squid/squid.conf no existeix o no es pot llegir."
exit 1
