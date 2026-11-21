#!/usr/bin/env bash
# Instala estas skills no PC atual.
#   ./install.sh                 Antigravity (agy) e Claude Code
#   ./install.sh agy             só Antigravity
#   ./install.sh claude          só Claude Code
#   ./install.sh maps            só o google-maps-scraper (baixa o binário)
#   ./install.sh conta2          cria o comando claude-work (segunda conta do Claude Code)
#   ./install.sh orquestrador    instala nova-conta e contas-status e cria o registro de contas
#   ./install.sh transcrever     cria o venv do Whisper (torch CPU) e o comando transcrever
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

conta2() {
  mkdir -p "$HOME/.local/bin" "$HOME/.claude-work"
  chmod 700 "$HOME/.claude-work"
  ln -sfn "$AQUI/bin/claude-work" "$HOME/.local/bin/claude-work"
  [ -e "$HOME/.claude-work/skills" ] || ln -s "$HOME/.claude/skills" "$HOME/.claude-work/skills"
  echo "ok: comando claude-work criado. Rode 'claude-work' e entre com a conta da empresa."
}

orquestrador() {
  mkdir -p "$HOME/.local/bin" "$HOME/.config/orquestrador"
  for c in nova-conta contas-status; do ln -sfn "$AQUI/bin/$c" "$HOME/.local/bin/$c"; done
  [ -f "$HOME/.config/orquestrador/contas.json" ] || echo '{"contas": []}' > "$HOME/.config/orquestrador/contas.json"
  echo "ok: nova-conta e contas-status instalados. Adicione contas: nova-conta claude|agy NOME [pessoal|empresa]"
}

transcrever() {
  local venv="${WHISPER_VENV:-/mnt/dados/venvs/whisper}"
  export UV_CACHE_DIR="${UV_CACHE_DIR:-/mnt/dados/uv-cache}"
  [ -x "$venv/bin/python" ] || uv venv "$venv" --python 3.12 -q
  uv pip install --python "$venv/bin/python" torch --index-url https://download.pytorch.org/whl/cpu
  uv pip install --python "$venv/bin/python" openai-whisper
  mkdir -p "$HOME/.local/bin"
  ln -sfn "$AQUI/bin/transcrever" "$HOME/.local/bin/transcrever"
  echo "ok: comando transcrever instalado (venv em $venv). O modelo baixa no primeiro uso."
}

case "$alvo" in
  agy|todos)    instala "$HOME/.gemini/config/skills" ;;&
  claude|todos) instala "$HOME/.claude/skills" ;;
  maps)         "$AQUI/ferramentas/maps/instalar-scraper.sh" ;;
  conta2)       conta2 ;;
  orquestrador) orquestrador ;;
  transcrever)  transcrever ;;
esac
