#!/bin/bash
# TITLE: El fitxer de configuració existeix
# DESCRIPTION: Comprova que /etc/ssh/sshd_config existeix i es pot llegir.

if [[ -r /etc/ssh/sshd_config ]]; then
    echo "/etc/ssh/sshd_config existeix i es pot llegir."
    exit 0
fi

echo "/etc/ssh/sshd_config no existeix o no es pot llegir."
exit 1
