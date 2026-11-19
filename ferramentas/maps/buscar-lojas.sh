#!/usr/bin/env bash
# Busca dados públicos de lojas no Google Maps para montar landing pages.
# Uso: ./buscar-lojas.sh "Nome da loja Brasília" ["Outra loja Brasília" ...]
# Uso consciente: poucas lojas por vez, uma já escolhida como lead. Não é para varrer a cidade.
# Segue devagar de propósito (1 tarefa por vez) para não ser bloqueado.
set -euo pipefail
[ $# -ge 1 ] || { echo "Passe ao menos uma busca"; exit 1; }
[ $# -le 15 ] || { echo "Máximo de 15 buscas por rodada"; exit 1; }
DIR="$(cd "$(dirname "$0")" && pwd)"
SAIDA="$DIR/mapas-saida"; mkdir -p "$SAIDA"
ARQ="$SAIDA/consultas-$(date +%H%M%S).txt"
printf '%s\n' "$@" > "$ARQ"
NOME="$(basename "$ARQ" .txt)"
cd "$SAIDA"
"$DIR/gmaps-scraper" -input "$ARQ" -results "$SAIDA/$NOME.json" -json \
  -depth 1 -c 1 -lang pt-BR -exit-on-inactivity 2m
python3 -I "$DIR/para-landing.py" "$SAIDA/$NOME.json"
