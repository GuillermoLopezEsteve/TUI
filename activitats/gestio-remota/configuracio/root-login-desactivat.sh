#!/bin/bash
# TITLE: L'accés remot com a root està desactivat
# DESCRIPTION: Comprova que sshd_config conté "PermitRootLogin no".

config="/etc/ssh/sshd_config"

if [[ ! -r "$config" ]]; then
    echo "$config no existeix o no es pot llegir."
    exit 2
fi

if grep -Eiq '^[[:space:]]*PermitRootLogin[[:space:]]+no' "$config"; then
    echo "L'accés remot com a root està desactivat."
    exit 0
fi

echo "$config no desactiva explícitament l'accés remot com a root (PermitRootLogin no)."
exit 1
