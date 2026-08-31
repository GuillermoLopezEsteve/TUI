#!/bin/bash
# TITLE: El fitxer de la zona directa existeix
# DESCRIPTION: Comprova que hi ha algun fitxer de zona a /etc/bind (per exemple db.lab.local).

if compgen -G "/etc/bind/db.*" >/dev/null 2>&1; then
    echo "S'ha trobat almenys un fitxer de zona a /etc/bind."
    exit 0
fi

echo "No s'ha trobat cap fitxer de zona (db.*) a /etc/bind."
exit 1
