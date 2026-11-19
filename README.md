# dev-toolkit

Ferramentas de trabalho para usar em qualquer PC: skills do Antigravity e do Claude Code, o google-maps-scraper
para montar landing pages e o comando para ter duas contas do Claude Code.

## Instalar em um PC novo
```bash
git clone git@github.com:Zackzinzz07/dev-toolkit.git
cd dev-toolkit
./install.sh            # skills no Antigravity e no Claude Code
./install.sh maps       # baixa o google-maps-scraper
./install.sh conta2     # cria o comando claude-work (conta empresarial)
./install.sh orquestrador   # comandos nova-conta e contas-status
nova-conta claude work empresa   # adiciona uma conta do Claude Code
nova-conta agy outra pessoal     # adiciona uma conta do Antigravity
```
Atualizar depois: `git pull`. As skills usam links, então já ficam atualizadas.

## O que tem aqui
- `skills/`: 78 skills (Django, front-end, marketing, SEO, privacidade, Git e trabalho em equipe).
  Elas ficam em pastas locais (`~/.gemini/config/skills`, `~/.claude/skills`) e não acompanham a conta, por isso o install.
- `ferramentas/maps/`: `buscar-lojas.sh "Loja Cidade"` busca dados públicos de uma loja no Google Maps e
  `para-landing.py` converte nos campos da landing page (nome, endereço, CEP, telefone, site, mapa, horário, fotos).
  Use só com lojas que já são lead, no máximo 15 por rodada. O Google pode bloquear o IP ou a conta, e a
  Places API oficial é a alternativa segura.
- `bin/nova-conta` e `bin/contas-status`: adicionam contas isoladas (Claude Code ou agy) e mostram login e cota de todas. A skill `orquestrador` usa esse registro, com uma ou mais contas de cada tipo.
- `bin/claude-work`: Claude Code com a conta empresarial, isolada da pessoal (`~/.claude-work`).

## Cuidados
- Não coloque chaves de API aqui, mesmo sendo privado.
- Cada skill vem de uma biblioteca de terceiros e mantém a licença original dentro da sua pasta.
