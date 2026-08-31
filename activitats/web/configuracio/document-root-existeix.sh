#!/bin/bash
# TITLE: El directori arrel de documents existeix
# DESCRIPTION: Comprova que /var/www/html existeix.

if [[ -d /var/www/html ]]; then
    echo "El directori /var/www/html existeix."
    exit 0
fi

echo "No s'ha trobat el directori /var/www/html."
exit 1
