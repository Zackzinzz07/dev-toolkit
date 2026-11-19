#!/usr/bin/env python3
"""Converte o resultado do scraper nos campos da landing page. Saída: <arquivo>.landing.json"""
import json, re, sys
from pathlib import Path

def linhas(p):
    t = Path(p).read_text(encoding="utf-8", errors="replace").strip()
    if t.startswith("["):
        return json.loads(t)
    return [json.loads(l) for l in t.splitlines() if l.strip()]

def cep(texto):
    m = re.search(r"\b\d{5}-?\d{3}\b", texto or "")
    return m.group(0) if m else None

saida = []
for r in linhas(sys.argv[1]):
    end = r.get("complete_address") or {}
    endereco = r.get("address") or ""
    saida.append({
        "nome": r.get("title"),
        "categoria": r.get("category"),
        "endereco": endereco,
        "cep": cep(endereco) or end.get("postal_code"),
        "telefone": r.get("phone"),
        "site": r.get("web_site"),
        "email": (r.get("emails") or [None])[0] if isinstance(r.get("emails"), list) else r.get("emails"),
        "latitude": r.get("latitude"), "longitude": r.get("longtitude") or r.get("longitude"),
        "link_mapa": r.get("link"),
        "horario": r.get("open_hours"),
        "nota": r.get("review_rating"), "avaliacoes": r.get("review_count"),
        "fotos": [i.get("image") for i in (r.get("images") or []) if isinstance(i, dict)][:6],
        "falta_pedir_ao_dono": ["cnpj", "logo", "produtos e preços", "texto sobre a loja"],
    })
destino = Path(sys.argv[1]).with_suffix(".landing.json")
destino.write_text(json.dumps(saida, ensure_ascii=False, indent=1), encoding="utf-8")
print(f"{len(saida)} loja(s) -> {destino}")
for s in saida: print("-", s["nome"], "|", s["endereco"], "| CEP", s["cep"], "|", s["telefone"], "|", s["site"])
