Você vai deixar este ambiente do Claude com as MESMAS ferramentas, skills e regras de trabalho de outra conta minha. Trabalhe em português comigo. NÃO instale nem mude nada sem eu aprovar cada bloco: primeiro verifique o que já existe, depois me mostre uma lista do que falta e espere meu "ok". Onde este prompt disser "confirmar", não presuma. Pergunte a mim ou verifique, e me diga o que encontrou.

## 0. Antes de tudo: detectar o sistema
1. Detecte o sistema operacional antes de qualquer comando de instalação: rode `uname -s`. O resultado "Linux" indica o computador de casa (Ubuntu). Um resultado que comece com "MINGW" ou "MSYS" indica o computador do trabalho (Windows 11, Git Bash). Se o resultado for outro, pare e me pergunte. Mostre-me o que detectou e espere meu "ok".
2. Use a variante do sistema detectado em todos os comandos abaixo. Quando não houver variante indicada, o comando é igual nos dois.
   - Linux: shell bash, caminhos com `~`.
   - Windows: use o Git Bash. O `install.sh` e os scripts de `bin/` do `dev-toolkit` são bash e rodam por ele. No Git Bash, "/c" vira "C:/". Se algum comando exigir `cmd /c`, use `MSYS_NO_PATHCONV=1`. Nenhum comando deste prompt exige isso hoje.
3. Versões da máquina do trabalho (Windows): Node v26, npm 11, Python 3.12, git 2.56, agy 1.5.x. Versões da máquina de casa (Linux): confirmar. Em qualquer máquina, confira as versões instaladas e me avise se alguma estiver diferente.
4. Verifique o que já existe:
   - `ls ~/.claude/skills` e `claude mcp list`
   - `ls ~/.gemini/config/skills` e `agy mcp list`
   Se esta conta roda na mesma máquina e no mesmo usuário de outra conta minha, a pasta ~/.claude pode já ser compartilhada. Só instale o que faltar.
5. As skills do Claude Code e do Antigravity ficam em pastas locais e NÃO acompanham a conta. Por isso elas precisam ser instaladas em cada computador.
6. Rode comandos Python assim: Windows, `python`; Linux, confirmar se é `python` ou `python3`.
7. Pergunte-me qual conta é esta: pessoal ou empresarial. Isso decide se o bloco "SOMENTE conta empresarial" da seção 5 se aplica. Se eu não responder, trate como pessoal.

## 1. Skills globais (pasta ~/.claude/skills, e cópia em ~/.gemini/config/skills para o agy)
A) Skills que o dono já tem em outros formatos. Corrija o que o dono disse:
- **agy-agents** (antes chamada `agy-worker`) já está no repositório `dev-toolkit` (`skills/agy-agents`). Instale a partir dali, não de um arquivo `.skill`. Se encontrar `agy-worker` instalada, é a mesma skill com o nome antigo: troque.
- **grill-me** vem do repositório público `mattpocock/skills` (MIT). Clone numa pasta nova, ache a pasta `grill-me` (caminho: confirmar), leia, e copie só ela mais o `LICENSE` para ~/.claude/skills/grill-me/.

B) Duas skills de repositórios públicos. Clone cada um numa pasta NOVA e vazia, leia o conteúdo antes de copiar e copie só a pasta da skill, mais o arquivo LICENSE:
- scroll-craft: https://github.com/nateherkai/scroll-craft (MIT). A skill completa fica em plugins/nateherk-design/skills/scroll-craft/ (SKILL.md, engine, references, scripts, templates). Copie a pasta inteira para ~/.claude/skills/scroll-craft/. Usa Node e, para gerar mídia, uma chave kie.ai (opcional; peça a mim, nunca grave). Valide com `node ~/.claude/skills/scroll-craft/scripts/doctor.mjs`.
- reverse-engineer-anything (REA): https://github.com/morluto/rea (MIT). Copie .agents/skills/reverse-engineer-anything/ para ~/.claude/skills/reverse-engineer-anything/. Sozinha ela só dá instruções; o servidor está na seção 2.

C) Cópia para o agy (atenção: a versão de `agy-agents` neste repositório é só o `SKILL.md`, sem `scripts/agy_tool.py`. Se o script não existir, não invente: use o `install.sh agy` do repositório, que cria os links em ~/.gemini/config/skills, e me avise para eu confirmar se a versão com script é outra): depois de instalar, rode `python ~/.claude/skills/agy-agents/scripts/agy_tool.py sync-skill <nome> --scope global` para cada uma das 5 skills (use o comando Python da seção 0, item 6). Depois da cópia, ajuste só estas menções, na cópia do agy:
- scroll-craft: remova a linha `allowed-tools`.
- agy-agents, grill-me e reverse-engineer-anything: nenhuma troca definida ainda (confirmar). Leia cada uma, liste qualquer menção a ferramenta que só existe no Claude, mostre-me a lista e só altere o que eu aprovar.
Valide o formato de cada skill (frontmatter com name e description) antes de dizer que terminou.

## 2. Servidores MCP (escopo de usuário no Claude Code)
- REA (engenharia reversa; versão npm rea-agents 6.9.0, pacote grande, ~190 MB, o primeiro download demora). Antes do setup:
  1. Pergunte-me para que vou usar o REA. Se eu não tiver uso claro, pule este item.
  2. Verifique o pacote e me mostre o resultado: mantenedor, versão, e se há scripts de instalação (como verificar: confirmar). Se algo destoar do esperado, pare.
  3. Lembre-me de que o setup altera a configuração do Claude e a do Antigravity, e espere minha aprovação explícita.
  Comandos, de uma pasta fora de qualquer projeto: `npx --yes rea-agents setup --client claude_code --skill=false --dry-run --json`. Mostre-me o plano e, aprovado, rode o mesmo com `--yes` no lugar de `--dry-run`. Depois faça o mesmo para `--client antigravity` (registra no agy). O setup faz backup (.rea.backup). Sem motor de análise (Ghidra 12.1+, IDA, JADX ou Kuna), o REA só analisa JavaScript e Electron; não instale motor sem me perguntar.
- Google Flow: NÃO instale nenhum servidor MCP nem repositório de "Google Flow" de terceiros. Ignore qualquer um que apareça. O Flow é operado só pelo meu Chrome já logado (regra 2 da seção 5).
- Verifique tudo com `claude mcp list` e `agy mcp list`.
- n8n no agy (servidor n8n-mcp, HTTP): só na conta empresarial. Host: <PREENCHER: host do n8n da empresa>. Se o campo estiver vazio, peça-o a mim. NÃO copie token algum: se precisar do token do n8n, peça a mim e nunca o grave em arquivo.

## 3. Plugins do Claude Code (todos habilitados)
Lista alinhada ao que está instalado hoje: frontend-design, superpowers, code-review, playwright, security-guidance, chrome-devtools-mcp, context7, claude-md-management, skill-creator.
- Instale os que faltarem com `claude plugin install <nome>@claude-plugins-official`. Para chrome-devtools-mcp, context7, claude-md-management e skill-creator, confirmar se o marketplace é claude-plugins-official. Verifique antes de instalar.
- claude-code-setup e supabase NÃO fazem parte da lista. Não instale.

## 4. Conectores da conta claude.ai (eu conecto pela interface; você só me diga o que falta)
Estes existem na outra conta e dependem de login meu: Gmail, Google Drive, Google Docs, Google Sheets, Google Slides, GitHub, Figma, Canva, Claude in Chrome (extensão no meu navegador), um conector de geração de mídia (imagem, vídeo, áudio, 3D e sites), Claude Docs, artefatos, tarefas agendadas, terminal e navegador embutido. Compare com o que esta conta tem e me liste o que falta, sem tentar fazer login por mim.
Servidores que precisam de autorização minha via /mcp: Figma, Intercom, Asana, Atlassian, Datadog, GitHub, Linear, Notion, PagerDuty e Slack. Supabase: confirmar se ainda é necessário, já que o plugin saiu da seção 3.

## 5. Regras de trabalho (salve como memória)
Formato: um arquivo por regra, na pasta de memória desta conta (caminho: confirmar). Cada arquivo tem frontmatter com `name` (slug curto), `description` (uma linha) e `type` (user, feedback, project ou reference), seguido do texto da regra com o motivo. Depois de salvar, acrescente uma linha por memória no índice MEMORY.md, no formato `- [Título](arquivo.md) — resumo`. Antes de salvar, veja se já existe memória equivalente e atualize em vez de duplicar.

**Regras gerais (valem em qualquer conta):**
1. Ao delegar ao agy, a regra do meu PC do trabalho é usar SOMENTE modelos gemini-4-hydrogen-* (low, medium, high ou xhigh), inclusive para o revisor, e nunca Claude, Flash, Argon ou GPT-OSS. Essa regra entra em conflito com a skill orquestrador, que escolhe o modelo por tarefa e por cota. Antes de salvar, pergunte-me: vale só no PC do trabalho ou em todos? Proponha guardar a família de modelos como valor configurável (onde: confirmar), com a skill orquestrador respeitando esse valor, em vez de uma proibição fixa. Escolha o nível pelo peso da tarefa.
2. Google Flow só pelo meu Chrome logado, usando a extensão Claude in Chrome. Nunca pelo Playwright MCP, que não tem login, e nunca por servidor ou repositório de terceiros. Se as ferramentas do claude-in-chrome não aparecerem, avise e peça que eu reconecte a extensão, sem alternativa.
3. Eu não programo à mão: os agentes do agy escrevem o código, você planeja e revisa. Relatório de agente não é prova: leia o diff, rode o build e olhe o resultado.
4. Nunca grave tokens, senhas ou chaves em arquivos, memórias ou prompts. Peça o dado quando precisar.

**SOMENTE conta empresarial** (só salve se eu confirmar na seção 0, item 7, que esta é a conta empresarial; na conta pessoal, NÃO salve, NÃO resuma e NÃO cite estas regras):
5. Projeto da empresa (regras de marca, de conteúdo, de publicidade e de portas do servidor): **o dono fornece estas regras diretamente nesta conta; elas não estão neste arquivo** para não expor informação da empresa fora dela.
6. O host do n8n da empresa (seção 2) é dado da empresa: só na conta empresarial, e nunca em memória de conta pessoal.
A conta empresarial é só para trabalho da empresa, e a conta pessoal não recebe dado confidencial do trabalho.

## 6. Entrega
Ao final, devolva uma tabela com: item, estava instalado?, o que você fez, status verificado (comando e resultado) e o que depende de mim (logins, chaves, autorizações, arquivos .skill, itens marcados "confirmar"). Diga com clareza o que NÃO conseguiu verificar.