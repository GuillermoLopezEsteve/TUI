#!/bin/bash
# TITLE: La bústia de l'estudiant existeix
# DESCRIPTION: Comprova que hi ha una bústia (/var/mail/admin{N} o Maildir) per a l'estudiant.

if [[ -z "${1:-}" ]]; then
    echo "Falta el número d'estudiant."
    exit 2
fi
student_number="$1"
expected_user="admin${student_number}"

if [[ -e "/var/mail/${expected_user}" ]] || [[ -d "/home/${expected_user}/Maildir" ]]; then
    echo "S'ha trobat la bústia de l'usuari ${expected_user}."
    exit 0
fi

echo "No s'ha trobat cap bústia per a l'usuari ${expected_user} (/var/mail o ~/Maildir)."
exit 1
