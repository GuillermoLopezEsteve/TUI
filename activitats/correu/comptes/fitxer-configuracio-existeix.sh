#!/bin/bash
# TITLE: El fitxer de configuració de Postfix existeix
# DESCRIPTION: Comprova que /etc/postfix/main.cf existeix i es pot llegir.

if [[ -r /etc/postfix/main.cf ]]; then
    echo "/etc/postfix/main.cf existeix i es pot llegir."
    exit 0
fi

echo "/etc/postfix/main.cf no existeix o no es pot llegir."
exit 1
