#!/bin/bash
# TITLE: El paquet OpenSSH està instal·lat
# DESCRIPTION: Comprova que el servidor openssh-server està instal·lat.

if dpkg -s openssh-server >/dev/null 2>&1 || command -v sshd >/dev/null 2>&1; then
    echo "OpenSSH està instal·lat."
    exit 0
fi

echo "No s'ha trobat openssh-server instal·lat."
exit 1
