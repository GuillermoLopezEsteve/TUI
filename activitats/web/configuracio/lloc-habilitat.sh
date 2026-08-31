#!/bin/bash
# TITLE: El lloc web està habilitat
# DESCRIPTION: Comprova que hi ha algun lloc habilitat a /etc/apache2/sites-enabled.

if compgen -G "/etc/apache2/sites-enabled/*.conf" >/dev/null 2>&1; then
    echo "Hi ha almenys un lloc habilitat."
    exit 0
fi

echo "No hi ha cap lloc habilitat a /etc/apache2/sites-enabled."
exit 1
