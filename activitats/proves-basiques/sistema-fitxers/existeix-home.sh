#!/bin/bash
# TITLE: El directori de l'usuari existeix
# DESCRIPTION: Comprova que la variable $HOME apunta a un directori existent.

if [[ -d "$HOME" ]]; then
    echo "El directori $HOME existeix."
    exit 0
fi

echo "El directori \$HOME ($HOME) no existeix."
exit 1
