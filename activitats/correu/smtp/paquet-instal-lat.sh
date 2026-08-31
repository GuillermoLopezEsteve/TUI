#!/bin/bash
# TITLE: El paquet Postfix està instal·lat
# DESCRIPTION: Comprova que el servidor SMTP Postfix està instal·lat.

if dpkg -s postfix >/dev/null 2>&1 || command -v postconf >/dev/null 2>&1; then
    echo "Postfix està instal·lat."
    exit 0
fi

echo "No s'ha trobat Postfix instal·lat."
exit 1
