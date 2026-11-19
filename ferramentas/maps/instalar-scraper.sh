#!/usr/bin/env bash
# Baixa o binário do google-maps-scraper (MIT, github.com/gosom/google-maps-scraper) para esta pasta.
# O binário não vai para o Git (tem ~76 MB); cada PC baixa o seu, na versão do sistema.
set -euo pipefail
cd "$(dirname "$0")"
VERSAO="1.19.0"
case "$(uname -s)" in
  MINGW*|MSYS*) SO="windows-amd64.exe"; BIN="gmaps-scraper.exe" ;;
  Darwin)       SO="darwin-amd64";      BIN="gmaps-scraper" ;;
  *)            SO="linux-amd64";       BIN="gmaps-scraper" ;;
esac
curl -L --fail -o "$BIN" \
  "https://github.com/gosom/google-maps-scraper/releases/download/v${VERSAO}/google_maps_scraper-${VERSAO}-${SO}"
chmod +x "$BIN"
echo "ok: $(pwd)/$BIN (v${VERSAO}). Na primeira busca ele baixa o navegador sozinho."
