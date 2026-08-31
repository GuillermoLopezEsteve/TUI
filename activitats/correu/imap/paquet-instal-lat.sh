#!/bin/bash
# TITLE: El paquet Dovecot està instal·lat
# DESCRIPTION: Comprova que el servidor IMAP Dovecot està instal·lat.

if dpkg -s dovecot-imapd >/dev/null 2>&1 || dpkg -s dovecot-core >/dev/null 2>&1 || command -v dovecot >/dev/null 2>&1; then
    echo "Dovecot està instal·lat."
    exit 0
fi

echo "No s'ha trobat Dovecot instal·lat."
exit 1
