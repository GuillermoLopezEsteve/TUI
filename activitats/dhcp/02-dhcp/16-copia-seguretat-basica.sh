#!/bin/bash
# TITLE: Existeix la còpia de seguretat kea-dhcp4.basic.conf.bak
# DESCRIPTION: Comprova que /etc/kea/kea-dhcp4.basic.conf.bak existeix, és a dir que s'ha desat la configuració bàsica d'eth1 abans d'afegir-hi la d'eth2.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

fitxer="/etc/kea/kea-dhcp4.basic.conf.bak"

fitxer_existeix "$fitxer"
case $? in
    0) correcte "$fitxer existeix." ;;
    1) falla "No existeix $fitxer. Desa una còpia de la configuració bàsica abans de configurar la subxarxa d'eth2." ;;
    *) no_comprovable "No es pot comprovar $fitxer: el directori /etc/kea no és accessible i sudo sense contrasenya no està disponible." ;;
esac
