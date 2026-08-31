#!/bin/bash
# TITLE: L'accés anònim està desactivat
# DESCRIPTION: Comprova que vsftpd.conf conté "anonymous_enable=NO".

config="/etc/vsftpd.conf"

if [[ ! -r "$config" ]]; then
    echo "$config no existeix o no es pot llegir."
    exit 2
fi

if grep -Eiq '^[[:space:]]*anonymous_enable[[:space:]]*=[[:space:]]*NO' "$config"; then
    echo "L'accés anònim està desactivat a $config."
    exit 0
fi

echo "$config no desactiva explícitament l'accés anònim (anonymous_enable=NO)."
exit 1
