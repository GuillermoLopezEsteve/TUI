#!/bin/bash
# TITLE: El fitxer de configuració existeix
# DESCRIPTION: Comprova que /etc/vsftpd.conf existeix i es pot llegir.

if [[ -r /etc/vsftpd.conf ]]; then
    echo "/etc/vsftpd.conf existeix i es pot llegir."
    exit 0
fi

echo "/etc/vsftpd.conf no existeix o no es pot llegir."
exit 1
