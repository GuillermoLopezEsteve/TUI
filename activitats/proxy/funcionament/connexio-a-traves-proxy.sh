#!/bin/bash
# TITLE: Es pot navegar a través del proxy
# DESCRIPTION: Comprova que una petició HTTP a través de 127.0.0.1:3128 obté resposta.

if ! command -v curl >/dev/null 2>&1; then
    echo "L'ordre curl no està instal·lada."
    exit 2
fi

if curl -s -o /dev/null -m 5 --proxy 127.0.0.1:3128 http://example.com; then
    echo "S'ha obtingut resposta a través del proxy."
    exit 0
fi

echo "No s'ha pogut navegar a través del proxy a 127.0.0.1:3128."
exit 1
