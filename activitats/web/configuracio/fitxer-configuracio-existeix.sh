#!/bin/bash
# TITLE: El fitxer de configuració del lloc per defecte existeix
# DESCRIPTION: Comprova que /etc/apache2/sites-available/000-default.conf existeix.

if [[ -r /etc/apache2/sites-available/000-default.conf ]]; then
    echo "El fitxer de configuració del lloc existeix."
    exit 0
fi

echo "No s'ha trobat /etc/apache2/sites-available/000-default.conf."
exit 1
