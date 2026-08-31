#!/bin/bash
# TITLE: El paquet vsftpd està instal·lat
# DESCRIPTION: Comprova que el servidor FTP vsftpd està instal·lat.

if dpkg -s vsftpd >/dev/null 2>&1 || command -v vsftpd >/dev/null 2>&1; then
    echo "vsftpd està instal·lat."
    exit 0
fi

echo "No s'ha trobat vsftpd instal·lat."
exit 1
