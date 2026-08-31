#!/bin/bash
# TITLE: El fitxer de configuració existeix
# DESCRIPTION: Comprova que /etc/bind/named.conf.local existeix i es pot llegir.

if [[ -r /etc/bind/named.conf.local ]]; then
    echo "/etc/bind/named.conf.local existeix i es pot llegir."
    exit 0
fi

echo "/etc/bind/named.conf.local no existeix o no es pot llegir."
exit 1
