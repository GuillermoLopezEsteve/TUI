#!/bin/bash
# TITLE: Els permisos del directori arrel són correctes
# DESCRIPTION: Comprova que /var/www/html es pot llegir.

docroot="/var/www/html"

if [[ ! -d "$docroot" ]]; then
    echo "$docroot no existeix."
    exit 1
fi

if [[ -r "$docroot" ]]; then
    echo "$docroot es pot llegir."
    exit 0
fi

echo "$docroot existeix però no es pot llegir."
exit 1
