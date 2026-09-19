#!/bin/bash
# TITLE: Les tres interfícies de xarxa estan actives
# DESCRIPTION: Comprova que hi ha 3 interfícies en estat UP sense comptar la de loopback.

source "$(dirname "$0")/../comu.sh" || { echo "Falta el fitxer comu.sh de l'activitat."; exit 2; }

cal_ordre ip

# "ip link show up" ja filtra per estat UP; només cal descartar la de loopback,
# que sempre està activa i no forma part de les 3 interfícies de l'activitat.
actives="$(ip -o link show up 2>/dev/null |
    awk '{n=$2; sub(/:$/,"",n); sub(/@.*/,"",n); if (n != "lo") print n}')"
total="$(grep -c . <<<"$actives")"

if (( total != 3 )); then
    falla "S'esperaven 3 interfícies de xarxa actives (UP), però n'hi ha $total: $(en_una_linia <<<"$actives" | sed 's/^$/cap/')."
fi

correcte "Hi ha 3 interfícies de xarxa actives: $(en_una_linia <<<"$actives")."
