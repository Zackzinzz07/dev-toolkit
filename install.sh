#!/usr/bin/env bash
# Instala estas skills no PC atual.
#   ./install.sh                 Antigravity (agy) e Claude Code
#   ./install.sh agy             só Antigravity
#   ./install.sh claude          só Claude Code
# Usa links simbólicos: depois de um "git pull" as skills se atualizam sozinhas.
set -euo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
alvo="${1:-todos}"

instala() {
  local destino="$1"
  mkdir -p "$destino"
  for s in "$AQUI"/skills/*/; do
    n="$(basename "$s")"
    if [ -e "$destino/$n" ] && [ ! -L "$destino/$n" ]; then
      echo "pulei $n em $destino (já existe e não é link)"; continue
    fi
    ln -sfn "${s%/}" "$destino/$n"
  done
  echo "ok: $(ls "$destino" | wc -l) skills em $destino"
}

case "$alvo" in
  agy|todos)    instala "$HOME/.gemini/config/skills" ;;&
  claude|todos) instala "$HOME/.claude/skills" ;;
esac
