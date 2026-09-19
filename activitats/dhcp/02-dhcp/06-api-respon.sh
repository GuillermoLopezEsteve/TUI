#!/bin/bash
# TITLE: L'API de control de Kea respon a config-get
# DESCRIPTION: Comprova que l'agent de control de Kea accepta les credencials i retorna la configuració del servei dhcp4.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

carrega_config_kea

subxarxes="$(llista_subxarxes)"
correcte "L'API de Kea a $KEA_URL ha retornat la configuració de dhcp4 (subxarxes definides: $subxarxes)."
