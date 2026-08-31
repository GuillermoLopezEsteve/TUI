#!/bin/bash
# TITLE: El paquet Apache està instal·lat
# DESCRIPTION: Comprova que el servidor web Apache (apache2) està instal·lat.

if dpkg -s apache2 >/dev/null 2>&1 || command -v apache2 >/dev/null 2>&1; then
    echo "Apache està instal·lat."
    exit 0
fi

echo "No s'ha trobat Apache instal·lat."
exit 1
