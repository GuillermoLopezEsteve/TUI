#!/bin/bash
# TITLE: El paquet del servidor DNS està instal·lat
# DESCRIPTION: Comprova que bind9 (o un servidor DNS equivalent) està instal·lat.

if dpkg -s bind9 >/dev/null 2>&1 || command -v named >/dev/null 2>&1; then
    echo "El servidor DNS està instal·lat."
    exit 0
fi

echo "No s'ha trobat cap servidor DNS instal·lat (bind9)."
exit 1
