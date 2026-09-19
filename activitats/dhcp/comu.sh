#!/bin/bash
# Funcions comunes de l'activitat DHCP.
#
# Aquest fitxer NO és una prova: viu a l'arrel de l'activitat, i el carregador
# només busca fitxers ".sh" dins de les carpetes de secció, així que no surt mai
# a la llista de proves.
#
# Ús des d'una prova:
#   source "$(dirname "$0")/../comu.sh" || { echo "Falta comu.sh."; exit 2; }

KEA_URL="${KEA_URL:-http://127.0.0.1:8000}"
KEA_FITXER_CONTRASENYA="${KEA_FITXER_CONTRASENYA:-/etc/kea/kea-api-password}"
KEA_FITXER_LEASES="${KEA_FITXER_LEASES:-/var/lib/kea/kea-leases4.csv}"

# --------------------------------------------------------------------------
# Resultats
# --------------------------------------------------------------------------

# correcte: l'estat comprovat és el que s'esperava.
correcte() { echo "$1"; exit 0; }

# falla: la comprovació s'ha pogut fer, però l'estat no és el correcte.
falla() { echo "$1"; exit 1; }

# no_comprovable: falta una eina o un permís i la prova no es pot dur a terme.
no_comprovable() { echo "$1"; exit 2; }

# --------------------------------------------------------------------------
# Número d'estudiant
# --------------------------------------------------------------------------

N=""

# llegeix_numero "$1" deixa el número d'estudiant validat a la variable N.
llegeix_numero() {
    if [[ ! "${1:-}" =~ ^[0-9]+$ ]]; then
        no_comprovable "Falta el número d'estudiant."
    fi
    if (( 10#$1 < 1 || 10#$1 > 100 )); then
        no_comprovable "El número d'estudiant ha de ser un enter entre 1 i 100, i s'ha rebut '$1'."
    fi
    N="$(( 10#$1 ))"
}

# --------------------------------------------------------------------------
# Eines i fitxers
# --------------------------------------------------------------------------

cal_ordre() {
    command -v "$1" >/dev/null 2>&1 || no_comprovable "L'ordre $1 no està instal·lada."
}

# fitxer_existeix <ruta>: 0 si hi és, 1 si no hi és, 2 si no es pot determinar.
# /etc/kea no és accessible per a un usuari normal, per això es torna a provar
# amb "sudo -n" (mai interactiu, perquè una prova no pot demanar contrasenya).
fitxer_existeix() {
    local ruta="$1" pare
    [[ -e "$ruta" ]] && return 0
    sudo -n test -e "$ruta" 2>/dev/null && return 0

    pare="$(dirname "$ruta")"
    if [[ ! -x "$pare" ]] && ! sudo -n true 2>/dev/null; then
        return 2
    fi
    return 1
}

# --------------------------------------------------------------------------
# Adreces IPv4
# --------------------------------------------------------------------------

# adreces_ipv4 <interfície>: escriu una adreça global per línia, sense màscara.
adreces_ipv4() {
    ip -4 -o addr show dev "$1" scope global 2>/dev/null | awk '{print $4}' | cut -d/ -f1
}

# mateixa_xarxa_24 <adreça> <adreça-de-xarxa>: cert si comparteixen els tres
# primers octets, que és el que defineix la pertinença a una xarxa /24.
mateixa_xarxa_24() {
    [[ "${1%.*}" == "${2%.*}" ]]
}

ip_a_enter() {
    local a b c d IFS=.
    read -r a b c d <<<"$1"
    printf '%s\n' "$(( (10#${a:-0} << 24) + (10#${b:-0} << 16) + (10#${c:-0} << 8) + 10#${d:-0} ))"
}

enter_a_ip() {
    printf '%s.%s.%s.%s\n' "$(( ($1 >> 24) & 255 ))" "$(( ($1 >> 16) & 255 ))" \
        "$(( ($1 >> 8) & 255 ))" "$(( $1 & 255 ))"
}

# --------------------------------------------------------------------------
# API de control de Kea
# --------------------------------------------------------------------------

# contrasenya_kea: llegeix la contrasenya de l'API directament si es pot, i si
# no amb "sudo -n". Retorna un codi diferent de zero si no s'ha pogut llegir.
contrasenya_kea() {
    if [[ -r "$KEA_FITXER_CONTRASENYA" ]]; then
        cat "$KEA_FITXER_CONTRASENYA"
        return 0
    fi
    sudo -n cat "$KEA_FITXER_CONTRASENYA" 2>/dev/null
}

# crida_kea <ordre>: envia una ordre a l'API i escriu la resposta sencera.
# Retorna 3 si no s'ha pogut llegir la contrasenya, i si no el codi de curl,
# per poder distingir un problema de permisos d'un servei que no respon.
crida_kea() {
    local ordre="$1" pw
    pw="$(contrasenya_kea)" || return 3
    [[ -n "$pw" ]] || return 3

    curl -sS -m 10 -X POST \
        -H "Content-Type: application/json" \
        -u "kea-api:${pw}" \
        -d "{\"command\":\"${ordre}\",\"service\":[\"dhcp4\"]}" \
        "$KEA_URL" 2>/dev/null
}

KEA_CONFIG=""

# carrega_config_kea: demana "config-get" i deixa l'objecte Dhcp4 a KEA_CONFIG.
# La configuració que retorna l'API ja té tots els valors per defecte resolts,
# de manera que les comprovacions no depenen de com s'hagi escrit el fitxer.
carrega_config_kea() {
    cal_ordre curl
    cal_ordre jq

    local resposta primer resultat estat
    resposta="$(crida_kea config-get)"
    estat=$?

    if (( estat == 3 )); then
        no_comprovable "No s'ha pogut llegir $KEA_FITXER_CONTRASENYA; cal permís de lectura o sudo sense contrasenya."
    fi
    if (( estat != 0 )) || [[ -z "$resposta" ]]; then
        falla "L'API de Kea a $KEA_URL no respon (curl ha retornat el codi $estat). Comprova que el servei kea-ctrl-agent estigui actiu i escoltant."
    fi

    # Una resposta correcta és una llista; els errors d'autenticació arriben
    # com un objecte solt, així que es tracten els dos casos igual.
    if ! primer="$(jq -ce 'if type == "array" then .[0] else . end' <<<"$resposta" 2>/dev/null)"; then
        falla "L'API de Kea no ha retornat JSON vàlid: $(head -c 120 <<<"$resposta" | tr '\n' ' ')"
    fi

    resultat="$(jq -r '.result // empty' <<<"$primer")"
    if [[ "$resultat" == "401" ]]; then
        falla "L'API de Kea rebutja les credencials (result 401). Revisa l'usuari kea-api i $KEA_FITXER_CONTRASENYA."
    fi
    if [[ "$resultat" != "0" ]]; then
        falla "L'ordre config-get ha retornat result=${resultat:-desconegut}: $(jq -r '.text // "sense text"' <<<"$primer")"
    fi

    KEA_CONFIG="$(jq -c '.arguments.Dhcp4 // empty' <<<"$primer")"
    if [[ -z "$KEA_CONFIG" ]]; then
        falla "La resposta de config-get no conté cap objecte Dhcp4."
    fi
}

# --------------------------------------------------------------------------
# Consultes jq sobre la configuració
# --------------------------------------------------------------------------

# Preàmbul jq compartit.
#
#   subxarxes  recull les subxarxes de primer nivell i també les que viuen dins
#              d'una "shared-network", conservant la xarxa pare.
#   cerca      localitza una subxarxa pel seu prefix.
#   opcio      resol una opció seguint l'ordre d'herència de Kea:
#              subxarxa -> shared-network -> global.
#   parametre  fa el mateix amb un paràmetre que no és una opció, com ara
#              "next-server" o "valid-lifetime".
JQ_COMU='
def subxarxes:
  [ (.subnet4 // [])[] | {sub: ., xarxa: null} ]
  + [ (."shared-networks" // [])[] as $x | ($x.subnet4 // [])[] | {sub: ., xarxa: $x} ];

def cerca($p): [ subxarxes[] | select(.sub.subnet == $p) ] | first;

def opcio($t; $nom):
     ( [ (($t.sub."option-data")   // [])[] | select(.name == $nom) ] | first )
  // ( [ (($t.xarxa."option-data") // [])[] | select(.name == $nom) ] | first )
  // ( [ ((."option-data")         // [])[] | select(.name == $nom) ] | first );

def parametre($t; $nom):
  ( $t.sub[$nom] ) // ( $t.xarxa[$nom] ) // ( .[$nom] );
'

# subxarxa <prefix>: escriu l'objecte JSON de la subxarxa, o res si no hi és.
subxarxa() {
    jq -c --arg p "$1" "$JQ_COMU"' cerca($p).sub // empty' <<<"$KEA_CONFIG"
}

# llista_subxarxes: prefixos definits, per al missatge d'error.
llista_subxarxes() {
    jq -r "$JQ_COMU"' [ subxarxes[].sub.subnet ] | if length == 0 then "cap" else join(", ") end' <<<"$KEA_CONFIG"
}

# opcio_subxarxa <prefix> <nom-opcio>: valor "data" de l'opció resolta.
opcio_subxarxa() {
    jq -r --arg p "$1" --arg n "$2" "$JQ_COMU"'
        cerca($p) as $t | opcio($t; $n).data // empty' <<<"$KEA_CONFIG"
}

# parametre_subxarxa <prefix> <nom>: valor del paràmetre resolt.
parametre_subxarxa() {
    jq -r --arg p "$1" --arg n "$2" "$JQ_COMU"'
        cerca($p) as $t | parametre($t; $n) // empty' <<<"$KEA_CONFIG"
}

# pools_subxarxa <prefix>: un rang per línia, tal com el retorna l'API.
pools_subxarxa() {
    jq -r --arg p "$1" "$JQ_COMU"' (cerca($p).sub.pools // [])[] | .pool' <<<"$KEA_CONFIG"
}

# reserves_subxarxa <prefix>: una adreça reservada per línia.
reserves_subxarxa() {
    jq -r --arg p "$1" "$JQ_COMU"'
        (cerca($p).sub.reservations // [])[] | .["ip-address"] // empty' <<<"$KEA_CONFIG"
}

# hostname_reserva <prefix> <adreça>: nom assignat a la reserva, o res.
hostname_reserva() {
    jq -r --arg p "$1" --arg ip "$2" "$JQ_COMU"'
        (cerca($p).sub.reservations // [])[]
        | select(.["ip-address"] == $ip) | .hostname // empty' <<<"$KEA_CONFIG"
}

# interficies_kea: una interfície per línia de "interfaces-config".
interficies_kea() {
    jq -r '(.["interfaces-config"].interfaces // [])[]' <<<"$KEA_CONFIG"
}

# --------------------------------------------------------------------------
# Rangs i llistes de valors
# --------------------------------------------------------------------------

# rang_pool <text>: normalitza un rang de Kea a "primera ultima".
# L'API retorna "A-B", però quan el rang coincideix exactament amb un prefix el
# retorna com "A/llargada", i per això cal cobrir les dues formes.
rang_pool() {
    local p="${1// /}" base llargada inici
    if [[ "$p" == */* ]]; then
        base="${p%%/*}"
        llargada="${p##*/}"
        [[ "$llargada" =~ ^[0-9]+$ ]] && (( llargada <= 32 )) || return 1
        inici="$(ip_a_enter "$base")"
        printf '%s %s\n' "$(enter_a_ip "$inici")" \
            "$(enter_a_ip "$(( inici + (1 << (32 - llargada)) - 1 ))")"
    elif [[ "$p" == *-* ]]; then
        printf '%s %s\n' "${p%%-*}" "${p##*-}"
    else
        return 1
    fi
}

# te_pool <prefix> <primera> <ultima>: cert si la subxarxa té aquest rang.
te_pool() {
    local prefix="$1" inici="$2" final="$3" pool
    while IFS= read -r pool; do
        [[ -n "$pool" ]] || continue
        [[ "$(rang_pool "$pool")" == "$inici $final" ]] && return 0
    done < <(pools_subxarxa "$prefix")
    return 1
}

# conte_valor <llista-separada-per-comes> <valor>: cert si hi és exactament.
conte_valor() {
    local llista="${1// /}" valor="$2" element IFS=,
    for element in $llista; do
        [[ "$element" == "$valor" ]] && return 0
    done
    return 1
}

# en_una_linia: ajunta una llista de línies en un sol text llegible.
en_una_linia() {
    tr '\n' ' ' | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//'
}

# --------------------------------------------------------------------------
# Concessions (leases)
# --------------------------------------------------------------------------
#
# Cada línia té el format:  adreça <TAB> estat <TAB> venciment <TAB> nom
# L'estat 0 vol dir concessió activa, i el venciment és un instant unix.

# leases_api: només funciona si el hook lease_cmds està carregat.
leases_api() {
    local resposta primer resultat
    resposta="$(crida_kea lease4-get-all)" || return 1
    [[ -n "$resposta" ]] || return 1
    primer="$(jq -ce 'if type == "array" then .[0] else . end' <<<"$resposta" 2>/dev/null)" || return 1

    resultat="$(jq -r '.result // empty' <<<"$primer")"
    case "$resultat" in
        0)
            jq -r '(.arguments.leases // [])[]
                   | [ .["ip-address"], (.state | tostring),
                       ((.cltt + .["valid-lft"]) | tostring), (.hostname // "") ]
                   | @tsv' <<<"$primer"
            ;;
        3) : ;;   # l'ordre existeix però no hi ha cap concessió
        *) return 1 ;;
    esac
}

# leases_fitxer: llegeix el memfile de Kea. Retorna 1 si no hi ha cap fitxer i
# 2 si existeix però no es pot llegir.
leases_fitxer() {
    local fitxer contingut="" tros trobat=0
    for fitxer in "$KEA_FITXER_LEASES" "${KEA_FITXER_LEASES}.2"; do
        [[ -e "$fitxer" ]] || sudo -n test -e "$fitxer" 2>/dev/null || continue
        trobat=1
        if [[ -r "$fitxer" ]]; then
            tros="$(cat "$fitxer")"
        else
            tros="$(sudo -n cat "$fitxer" 2>/dev/null)" || return 2
        fi
        contingut+="$tros"$'\n'
    done
    (( trobat )) || return 1

    # Columnes del memfile: address,hwaddr,client_id,valid_lifetime,expire,
    # subnet_id,fqdn_fwd,fqdn_rev,hostname,state,user_context,pool_id.
    # El fitxer és d'afegits: per a cada adreça només val l'última línia.
    awk -F, '$1 != "address" && NF >= 10 {
                 est[$1] = $10; venc[$1] = $5; nom[$1] = $9
             }
             END { for (a in est) printf "%s\t%s\t%s\t%s\n", a, est[a], venc[a], nom[a] }' \
        <<<"$contingut"
}

LEASES=""

# carrega_leases: deixa les concessions a LEASES, provant primer l'API.
carrega_leases() {
    local sortida estat
    if sortida="$(leases_api)"; then
        LEASES="$sortida"
        return 0
    fi

    sortida="$(leases_fitxer)"
    estat=$?
    case "$estat" in
        0) LEASES="$sortida" ;;
        1) no_comprovable "No s'ha trobat el fitxer de concessions $KEA_FITXER_LEASES ni l'ordre lease4-get-all està disponible." ;;
        *) no_comprovable "No es pot llegir $KEA_FITXER_LEASES; cal permís de lectura o sudo sense contrasenya." ;;
    esac
}

# lease_activa <adreça>: cert si hi ha una concessió vigent per a l'adreça.
lease_activa() {
    local objectiu="$1" ara adreca estat venciment
    ara="$(date +%s)"
    while IFS=$'\t' read -r adreca estat venciment _; do
        [[ "$adreca" == "$objectiu" ]] || continue
        [[ "$estat" == "0" ]] || continue
        [[ "$venciment" =~ ^[0-9]+$ ]] && (( venciment > ara )) && return 0
    done <<<"$LEASES"
    return 1
}

# leases_actives_al_rang <primera> <ultima>: escriu les adreces vigents dins
# del rang indicat, una per línia.
leases_actives_al_rang() {
    local inici final ara adreca estat venciment valor
    inici="$(ip_a_enter "$1")"
    final="$(ip_a_enter "$2")"
    ara="$(date +%s)"
    while IFS=$'\t' read -r adreca estat venciment _; do
        [[ "$adreca" =~ ^[0-9.]+$ ]] || continue
        [[ "$estat" == "0" ]] || continue
        [[ "$venciment" =~ ^[0-9]+$ ]] && (( venciment > ara )) || continue
        valor="$(ip_a_enter "$adreca")"
        (( valor >= inici && valor <= final )) && printf '%s\n' "$adreca"
    done <<<"$LEASES"
}
