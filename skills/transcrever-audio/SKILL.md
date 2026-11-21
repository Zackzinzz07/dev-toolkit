---
name: transcrever-audio
description: Transcreve áudios localmente com Whisper (large-v3-turbo, 100% offline, sem API key) usando o comando `transcrever`. Use quando o usuário pedir para transcrever, ouvir, ler ou resumir um áudio, nota de voz do WhatsApp (.ogg/.opus), gravação de reunião, aula ou vídeo, ou disser "os últimos áudios que baixei", "vê o que tem nesse áudio", "passa esse áudio pra texto".
---

# Transcrever áudio (Whisper local)

Ferramenta do dev-toolkit. Roda no CPU, não manda nada para a nuvem.

## Comando

```bash
transcrever --ultimos 2                    # 2 áudios mais recentes de ~/Transferências (ou ~/Downloads)
transcrever caminho/audio.ogg outro.mp3    # arquivos específicos
transcrever --ultimos 1 --saida <pasta>/   # também grava <nome>.md por áudio
transcrever --modelo small audio.ogg       # mais rápido, menos preciso (tiny/base/small/medium/large-v3-turbo)
transcrever --idioma auto audio.mp3        # detectar idioma (padrão: pt)
```

- Texto sai no **stdout** (bloco `### nome-do-arquivo` por áudio). Progresso e tempos saem no stderr.
- Padrão `large-v3-turbo`: ótimo em português. Em CPU leva aprox. 1x a 2x a duração do áudio, mais uns 15s para carregar o modelo. Para áudio longo (mais de 20 min), rode em background.
- Formatos: ogg, opus, mp3, m4a, wav, flac, webm, aac, mp4, mkv, mov (usa ffmpeg).

## Fluxo

1. Identifique os arquivos (`ls -lt ~/Transferências | head` se o usuário disser "os últimos").
2. Rode `transcrever ...` e leia o texto.
3. Entregue: transcrição fiel + resumo curto (quem fala, pedidos, números, datas, tarefas).
4. **No Segundo Cérebro** (`~/Documents/Segundo Cerebro`): siga o protocolo de captura do `CLAUDE.md` do vault. A transcrição bruta vai para o objeto a que serve (cliente: `clientes/<slug>/`, reunião: `reunioes/`, estudo: `conhecimento/raw/`). Fatos novos viram registros nas notas certas e tarefas vão para `tasks/todo.md`.

## Problemas comuns

- `Venv do Whisper não encontrado`: rode `~/dev-toolkit/install.sh transcrever`.
- Modelo some do cache: ele baixa de novo sozinho para `/mnt/dados/cache/whisper` (1,6 GB). Defina `WHISPER_CACHE` para outro lugar se precisar.
- Windows (PC do trabalho): o wrapper é bash; use `python transcrever.py` direto de `ferramentas/transcrever/` com um venv que tenha `openai-whisper`.
