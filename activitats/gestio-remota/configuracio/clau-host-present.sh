#!/bin/bash
# TITLE: Hi ha una clau d'amfitrió generada
# DESCRIPTION: Comprova que existeix almenys una clau d'amfitrió SSH (RSA o ED25519).

if [[ -e /etc/ssh/ssh_host_rsa_key ]] || [[ -e /etc/ssh/ssh_host_ed25519_key ]]; then
    echo "S'ha trobat una clau d'amfitrió SSH."
    exit 0
fi

echo "No s'ha trobat cap clau d'amfitrió SSH a /etc/ssh."
exit 1
