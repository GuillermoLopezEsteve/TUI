#!/bin/bash
# TITLE: El paquet Squid està instal·lat
# DESCRIPTION: Comprova que el servidor proxy Squid està instal·lat.

if dpkg -s squid >/dev/null 2>&1 || command -v squid >/dev/null 2>&1; then
    echo "Squid està instal·lat."
    exit 0
fi

echo "No s'ha trobat Squid instal·lat."
exit 1
