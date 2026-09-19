#!/bin/bash
# TITLE: Existeix la còpia de seguretat kea-dhcp4.conf.bak
# DESCRIPTION: Comprova que /etc/kea/kea-dhcp4.conf.bak existeix, és a dir que s'ha desat la configuració original abans de modificar-la.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

fitxer="/etc/kea/kea-dhcp4.conf.bak"

fitxer_existeix "$fitxer"
case $? in
    0) correcte "$fitxer existeix." ;;
    1) falla "No existeix $fitxer. Fes una còpia de seguretat de la configuració original de Kea." ;;
    *) no_comprovable "No es pot comprovar $fitxer: el directori /etc/kea no és accessible i sudo sense contrasenya no està disponible." ;;
esac
