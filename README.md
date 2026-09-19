# LabCheck (smx2-checker)

Aplicació de terminal per a les activitats de laboratori de SMX2. Comprova la teva màquina
(DHCP, DNS, etc.) i et diu, per a cada prova, què està bé i què no. No configura res per tu:
només et diu com estàs.

## Instal·lació

Necessites Ubuntu i tenir `curl` instal·lat (normalment ja hi és). Executa:

```bash
curl -LO https://raw.githubusercontent.com/GuillermoLopezEsteve/TUI/master/install.sh
bash install.sh
```

Això instal·la el Go i el git si et falten, baixa el codi i instal·la l'ordre
`smx2-checker`. Si ja havies fet aquest pas abans, torna-ho a executar per actualitzar-ho tot.

Un cop acabat, obre una terminal nova (o executa `source ~/.bashrc`) perquè `smx2-checker`
funcioni.

## Executar

```bash
smx2-checker
```

La primera vegada et demanarà el número d'estudiant (1–100) i després mostrarà la llista
d'activitats. Tecles bàsiques:

- `↑`/`↓` — moure's
- `Enter` — obrir una activitat / executar la prova
- `a` — executar totes les proves de la secció
- `t` — veure l'script d'una prova
- `U` — canviar el número d'estudiant
- `C` — enrere
- `Esc` / `Ctrl+C` — sortir

## Actualitzar

Torna a executar els mateixos dos comandaments de la instal·lació.

## Desinstal·lar

Dins de la carpeta `TUI`:

```bash
make uninstall
```

## Més informació

L'especificació completa del format de les activitats es troba a
[`requirments/`](./requirments/00-overview.md).
