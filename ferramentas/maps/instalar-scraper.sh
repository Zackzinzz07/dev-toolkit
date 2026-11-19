#!/usr/bin/env bash
# Baixa o binário do google-maps-scraper (MIT, github.com/gosom/google-maps-scraper) para esta pasta.
# O binário não vai para o Git (tem 76 MB); cada PC baixa o seu.
set -euo pipefail
cd "$(dirname "$0")"
VERSAO="1.19.0"
curl -L --fail -o gmaps-scraper \
  "https://github.com/gosom/google-maps-scraper/releases/download/v${VERSAO}/google_maps_scraper-${VERSAO}-linux-amd64"
chmod +x gmaps-scraper
echo "ok: $(pwd)/gmaps-scraper (v${VERSAO}). Na primeira busca ele baixa o navegador sozinho."
