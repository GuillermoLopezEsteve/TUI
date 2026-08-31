#!/bin/bash
# TITLE: Hi ha connexió a Internet
# DESCRIPTION: Comprova que es pot fer ping a 8.8.8.8.

if ! command -v ping >/dev/null 2>&1; then
    echo "L'ordre ping no està instal·lada."
    exit 1
fi

if ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
    echo "Hi ha connexió a Internet."
    exit 0
fi

echo "No s'ha pogut fer ping a 8.8.8.8. Comprova la connexió de xarxa."
exit 1
