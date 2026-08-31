#!/bin/bash
# TITLE: El directori arrel FTP existeix
# DESCRIPTION: Comprova que el directori /srv/ftp existeix.

if [[ -d /srv/ftp ]]; then
    echo "El directori /srv/ftp existeix."
    exit 0
fi

echo "No s'ha trobat el directori /srv/ftp."
exit 1
