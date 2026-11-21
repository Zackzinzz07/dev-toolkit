"""Transcreve áudios localmente com Whisper (sem nuvem, sem API key).

Uso (via wrapper bin/transcrever):
    transcrever arquivo1.ogg [arquivo2.mp3 ...]
    transcrever --ultimos 2                 # os 2 áudios mais recentes em ~/Transferências
    transcrever --ultimos 2 --saida pasta/  # grava um .md por áudio na pasta
    transcrever --modelo small audio.ogg    # modelo mais leve (mais rápido, menos preciso)

Saída: texto no stdout (um bloco por arquivo). Com --saida, também grava <nome>.md.
"""
import argparse
import os
import sys
import time
from datetime import datetime
from pathlib import Path

EXTS = {".ogg", ".opus", ".mp3", ".m4a", ".wav", ".flac", ".webm", ".aac", ".mp4", ".mkv", ".mov"}
PASTAS_DOWNLOAD = [Path.home() / "Transferências", Path.home() / "Downloads"]
CACHE_MODELOS = os.environ.get(
    "WHISPER_CACHE",
    str(Path(os.environ.get("XDG_CACHE_HOME", "/mnt/dados/cache")) / "whisper"),
)


def ultimos_audios(n: int) -> list[Path]:
    achados = []
    for pasta in PASTAS_DOWNLOAD:
        if pasta.is_dir():
            achados += [p for p in pasta.iterdir() if p.is_file() and p.suffix.lower() in EXTS]
    achados.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    return sorted(achados[:n], key=lambda p: (p.stat().st_mtime, p.name))  # mais antigo primeiro; empate pelo nome (WhatsApp põe a hora no nome)


def main() -> int:
    ap = argparse.ArgumentParser(description="Transcrição local com Whisper")
    ap.add_argument("arquivos", nargs="*", type=Path)
    ap.add_argument("--ultimos", type=int, help="pega os N áudios mais recentes de ~/Transferências")
    ap.add_argument("--modelo", default=os.environ.get("WHISPER_MODELO", "large-v3-turbo"))
    ap.add_argument("--idioma", default="pt", help="código do idioma ou 'auto'")
    ap.add_argument("--saida", type=Path, help="pasta onde gravar um .md por áudio")
    a = ap.parse_args()

    arquivos = list(a.arquivos) + (ultimos_audios(a.ultimos) if a.ultimos else [])
    if not arquivos:
        ap.error("informe arquivos ou --ultimos N")
    for f in arquivos:
        if not f.is_file():
            print(f"arquivo não encontrado: {f}", file=sys.stderr)
            return 1

    import whisper  # import tardio: só carrega torch quando há trabalho

    print(f"[transcrever] modelo {a.modelo} (cache {CACHE_MODELOS})", file=sys.stderr)
    modelo = whisper.load_model(a.modelo, download_root=CACHE_MODELOS)
    if a.saida:
        a.saida.mkdir(parents=True, exist_ok=True)

    for f in arquivos:
        t0 = time.time()
        r = modelo.transcribe(
            str(f),
            language=None if a.idioma == "auto" else a.idioma,
            fp16=False,
            verbose=False,
        )
        texto = r["text"].strip()
        dur = r["segments"][-1]["end"] if r["segments"] else 0
        print(f"[transcrever] {f.name}: {dur:.0f}s de áudio em {time.time() - t0:.0f}s", file=sys.stderr)
        print(f"### {f.name}\n\n{texto}\n")
        if a.saida:
            data = datetime.fromtimestamp(f.stat().st_mtime).strftime("%Y-%m-%d %H:%M")
            (a.saida / f"{f.stem}.md").write_text(
                f"# Transcrição: {f.name}\n\n"
                f"- **Arquivo:** `{f}`\n- **Data do arquivo:** {data}\n"
                f"- **Duração:** {dur:.0f}s\n- **Modelo:** whisper {a.modelo} (local)\n\n"
                f"## Texto\n\n{texto}\n",
                encoding="utf-8",
            )
    return 0


if __name__ == "__main__":
    sys.exit(main())
