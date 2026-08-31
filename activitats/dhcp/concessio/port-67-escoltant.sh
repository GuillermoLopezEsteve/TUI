#!/bin/bash
# TITLE: El servei escolta al port 67 (DHCP/BOOTP)
# DESCRIPTION: Comprova que hi ha un procés escoltant peticions UDP al port 67.

if ! command -v ss >/dev/null 2>&1; then
    echo "L'ordre ss no està disponible en aquest sistema."
    exit 2
fi

if ss -lun 2>/dev/null | grep -q ':67[[:space:]]'; then
    echo "Hi ha un procés escoltant al port UDP 67."
    exit 0
fi

echo "Cap procés escolta al port UDP 67."
exit 1
