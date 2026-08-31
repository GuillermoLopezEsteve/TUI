#!/bin/bash
# TITLE: El servei escolta al port 53
# DESCRIPTION: Comprova que hi ha un procés escoltant connexions al port 53 (TCP o UDP).

if ! command -v ss >/dev/null 2>&1; then
    echo "L'ordre ss no està disponible en aquest sistema."
    exit 2
fi

if ss -ltun 2>/dev/null | grep -q ':53[[:space:]]'; then
    echo "Hi ha un procés escoltant al port 53."
    exit 0
fi

echo "Cap procés escolta al port 53."
exit 1
