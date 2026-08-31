#!/bin/bash
# TITLE: El servidor web escolta al port 80
# DESCRIPTION: Comprova que hi ha un procés escoltant connexions TCP al port 80.

if ! command -v ss >/dev/null 2>&1; then
    echo "L'ordre ss no està disponible en aquest sistema."
    exit 2
fi

if ss -ltn 2>/dev/null | grep -q ':80[[:space:]]'; then
    echo "Hi ha un procés escoltant al port 80."
    exit 0
fi

echo "Cap procés escolta al port 80."
exit 1
