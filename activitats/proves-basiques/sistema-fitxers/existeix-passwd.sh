#!/bin/bash
# TITLE: El fitxer /etc/passwd existeix
# DESCRIPTION: Comprova que /etc/passwd existeix i es pot llegir.

if [[ -r /etc/passwd ]]; then
    echo "/etc/passwd existeix i es pot llegir."
    exit 0
fi

echo "/etc/passwd no existeix o no es pot llegir."
exit 1
