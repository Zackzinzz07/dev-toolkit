# dev-toolkit

## 1. O que é e para quem

Repositório privado (`git@github.com:Zackzinzz07/dev-toolkit.git`) com ferramentas de trabalho para usar em qualquer computador. Reúne as skills do Antigravity (`agy`) e do Claude Code, o scraper do Google Maps para montar landing pages e os comandos para gerenciar várias contas isoladas.

- **Dono:** Isac Salatiel (estagiário de tecnologia, Brasília).
- **Ambientes do dono:** computador de casa (Ubuntu, Linux) e computador do trabalho (Windows 11, com Git Bash e PowerShell).
- **Público deste documento:** o Claude do computador do trabalho e o próprio dono. O Claude deve ler e entender tudo antes de agir e só executar a instalação com aprovação do dono.

---

## 2. O que tem aqui

- **`skills/` (Skills):**
  - 79 skills para Claude Code e Antigravity (`agy`), nas áreas de Django, front-end, marketing, SEO, privacidade, Git e trabalho em equipe.
  - Inclui as skills `orquestrador` e `google-flow`.
  - Ficam instaladas via links em pastas locais (`~/.gemini/config/skills` e `~/.claude/skills`). Elas não acompanham a conta na nuvem.
  - Cada skill vem de uma biblioteca de terceiros e mantém a licença original dentro da sua pasta.
- **Orquestrador (`orquestrador`):**
  - Skill que utiliza o registro local de contas em `~/.config/orquestrador/contas.json`, operando com uma ou mais contas do Claude Code e do `agy`.
- **Scraper do Maps (`ferramentas/maps/`):**
  - Usa o `google-maps-scraper` para extrair dados públicos e montar landing pages.
  - `buscar-lojas.sh "Loja Cidade"`: busca dados públicos de uma loja no Google Maps.
  - `para-landing.py`: converte os dados encontrados nos campos da landing page (nome, endereço, CEP, telefone, site, mapa, horário, fotos).
- **`agy-agents`:** skill para o Claude delegar código, testes e documentação ao Antigravity (`agy`), escolhendo o modelo e revisando o resultado. 
- **Contas (`bin/`):**
  - `bin/nova-conta`: adiciona contas isoladas do Claude Code ou do `agy`.
  - `bin/contas-status`: mostra o status de login e a cota de todas as contas registradas.
  - `bin/claude-work`: executa o Claude Code com a conta empresarial, isolada da conta pessoal na pasta `~/.claude-work`.

---

## 3. Instalação passo a passo no Linux e no Windows (Git Bash)

`install.sh` e os scripts em `bin/` são escritos em bash.
- **No Linux (Ubuntu):** rode os comandos no terminal bash.
- **No Windows 11:** rode todos os comandos pelo **Git Bash** (não pelo PowerShell).
- **Pré-requisitos:** `git`, `bash`, `python3`, `curl`, o Claude Code (`claude`) e, para o Antigravity, o `agy`. Os comandos ficam em `~/.local/bin`, que precisa estar no `PATH` (confira com `echo $PATH`).
- **Regra obrigatória:** o Claude do computador do trabalho precisa pedir aprovação do dono antes de iniciar.

### Passo 1: Clonar o repositório e entrar na pasta
```bash
git clone git@github.com:Zackzinzz07/dev-toolkit.git
cd dev-toolkit
```
- **Verificação:** `ls` deve mostrar `install.sh`, `skills/`, `ferramentas/maps/` e `bin/`.

### Passo 2: Instalar as skills no Antigravity e no Claude Code
```bash
./install.sh
```
- **Verificação:** `ls ~/.claude/skills | wc -l` e `ls ~/.gemini/config/skills | wc -l` devem mostrar pelo menos 78. O script avisa "pulei X" para as skills que já existem como pasta comum; isso é normal.

### Passo 3: Instalar o scraper do Google Maps
```bash
./install.sh maps
```
- **Verificação:** `ls -la ferramentas/maps/gmaps-scraper` deve mostrar um arquivo de ~76 MB. No Windows o binário é outro: **a confirmar** (o script baixa a versão Linux).

### Passo 4: Criar o comando da conta empresarial (`claude-work`)
```bash
./install.sh conta2
```
- **Verificação:** `command -v claude-work` deve mostrar o caminho em `~/.local/bin`. Depois rode `claude-work` e entre com a conta da empresa.

### Passo 5: Instalar os comandos do orquestrador
```bash
./install.sh orquestrador
```
- **Verificação:** `command -v nova-conta contas-status` deve listar os dois.

### Passo 6: Adicionar as contas isoladas
```bash
nova-conta claude work empresa   # adiciona uma conta do Claude Code
nova-conta agy outra pessoal     # adiciona uma conta do Antigravity
```
- **Verificação:** `nova-conta lista` mostra as contas registradas e `contas-status` mostra login e cota. Cada conta nova exige que o dono rode o comando dela (`claude-NOME` ou `agy-NOME`) e faça o login.

### Atualização futura
```bash
git pull
```
- **Verificação:** como as skills usam links para o repositório, elas ficam atualizadas automaticamente após o `git pull` (verificação adicional: a confirmar).

---

## 4. Como funcionam as várias contas

- **Isolamento:** é possível ter várias contas do Claude Code e várias do Antigravity (`agy`), cada uma isolada da outra. As skills ficam nas pastas locais da máquina e não acompanham a conta.
- **`claude-work` (`bin/claude-work`):** atalho criado por `./install.sh conta2` para abrir o Claude Code na conta empresarial, mantendo os dados isolados em `~/.claude-work`.
- **`nova-conta` (`bin/nova-conta`):** `nova-conta claude|agy NOME [pessoal|empresa]` cria o comando `claude-NOME` ou `agy-NOME`, isolado das outras contas, e registra a conta. `nova-conta lista` mostra todas.
- **`contas-status` (`bin/contas-status`):** mostra se cada Claude está logado e a cota de cada agy (Gemini e Claude, semana e janela de 5 horas).
- **Registro (`~/.config/orquestrador/contas.json`):** um arquivo por PC. Cada conta tem `nome`, `tipo` (`claude` ou `agy`), `comando`, `escopo`, `config` e `ativa` (`false` pausa a conta, por exemplo quando a cota da semana acabou).
- **Escopo pessoal x empresa:**
  - A **conta empresarial** é exclusiva para trabalho da empresa.
  - A **conta pessoal** nunca deve receber dados confidenciais do trabalho.

---

## 5. Como o orquestrador escolhe conta, modelo e effort

- **Conta:** respeita o escopo (empresa só em conta de empresa); usa só contas ativas e logadas; entre as elegíveis, a de maior cota livre, dividindo o trabalho entre elas. Semana abaixo de 10%: a conta fica fora. Janela de 5 horas abaixo de 20%: menos paralelismo. Se todas as do escopo esgotarem, para e avisa o dono.
- **Modelo:** modelo é capacidade; effort é o quanto ele trabalha. Haiku para ler e buscar, Sonnet como padrão, Opus para problema ambíguo. No agy: flash para pesquisa em volume, argon para escrita e auditoria, hydrogen para scripts e testes, Claude para revisão. Veja o `skills/orquestrador/SKILL.md` para a tabela completa.
- **Effort:** `medium` por padrão. Sobe um nível se pulou arquivo ou teste; sobe de modelo se errou com confiança tendo todo o contexto; desce quando o trabalho vira rotina. Nunca `max` como padrão.
- **Atenção:** a regra do PC do trabalho de usar só `gemini-4-hydrogen-*` no agy pode conflitar com isso. O dono decide se vale só lá ou em todos.

---

## 6. Regras de segurança e limites

- **Aprovação prévia:** o Claude do computador do trabalho só pode instalar após aprovação do dono.
- **Separação de dados:** conta empresarial apenas para atividades da empresa; proibido enviar dado confidencial do trabalho para conta pessoal.
- **Sem chaves no repositório:** nunca colocar chaves de API no `dev-toolkit`, mesmo sendo um repositório privado.
- **Google Flow:** ignorar qualquer repositório ou servidor MCP de Flow de terceiros. O Flow é operado só pelo Chrome do dono, já logado, por um conector restrito (seção 9).
- **Limites do scraper do Google Maps (`ferramentas/maps/`):**
  - Usar somente com lojas que já são lead.
  - Limite máximo de **15 lojas por rodada**.
  - Risco: o Google pode bloquear o IP ou a conta. A alternativa segura é a Places API oficial.
- **Licenças:** manter a licença original de terceiros dentro da pasta de cada skill em `skills/`.

---

## 7. Problemas comuns

- **Skills não aparecem em um PC novo ou após trocar de conta:** as skills não sincronizam pela conta; ficam em `~/.gemini/config/skills` e `~/.claude/skills`. Rode `./install.sh` na máquina local.
- **Erro ao rodar `install.sh` ou scripts de `bin/` no Windows 11:** os scripts são em bash. Execute sempre pelo **Git Bash**.
- **Bloqueio de IP ou de conta pelo Google ao buscar lojas:** causado pelo uso do `google-maps-scraper`. Respeite o teto de 15 lojas (que já sejam lead) por rodada ou migre para a Places API oficial.
- **Outros erros de instalação, permissão ou autenticação:** a confirmar.

---

## 8. O que ainda precisa de login ou ação manual do dono

- **Aprovar a instalação:** autorizar o Claude do computador do trabalho a rodar os comandos do `./install.sh`.
- **Acesso SSH ao GitHub:** estar autenticado com acesso à conta `Zackzinzz07` para clonar `git@github.com:Zackzinzz07/dev-toolkit.git` (passos de configuração da chave SSH: a confirmar).
- **Login nas contas do Claude Code e do Antigravity (`agy`):** autenticar manualmente cada conta isolada criada com `nova-conta` e a conta empresarial em `claude-work`, conferindo depois com `contas-status` (fluxo exato de login de cada CLI: a confirmar).
- **Login no Google Chrome para o Google Flow:** deixar a conta do dono já logada no Chrome antes de usar a skill `google-flow`.
- **Demais ações manuais pendentes:** a confirmar.

---

## 9. Plugins do Claude Code

Plugins ficam por conta (`~/.claude` e `~/.claude-NOME`). Instalar em cada conta, com o marketplace oficial `claude-plugins-official`:

| Plugin | Para que serve |
|---|---|
| `superpowers` | fluxos de trabalho: planejar, depurar, revisar, TDD |
| `code-review` | revisão de código |
| `frontend-design` | design de interface com critério estético |
| `security-guidance` | revisão de segurança automática dos commits |
| `claude-md-management` | manter o CLAUDE.md |
| `skill-creator` | criar e testar skills |
| `context7` | documentação de bibliotecas atualizada |
| `playwright` | automação de navegador |
| `chrome-devtools-mcp` | controle do Chrome (usado no conector do Flow, seção 10) |

```bash
for p in superpowers code-review frontend-design security-guidance claude-md-management skill-creator context7 playwright chrome-devtools-mcp; do
  claude plugin install "$p@claude-plugins-official" --scope user
done
```
Para uma conta isolada, rode antes `export CLAUDE_CONFIG_DIR=~/.claude-NOME` (ou use o comando da conta). Os plugins `figma` e `engineering` vêm da sincronização do claude.ai e aparecem sozinhos conforme a conta. Confira com `claude plugin list`. O `chrome-devtools-mcp` e o `playwright` controlam navegador: confira se a empresa permite.

## 9b. Skills que vêm de outros repositórios

| Skill | Origem | Licença | Situação |
|---|---|---|---|
| `agy-agents` | já está em `skills/agy-agents` deste repositório | própria | instalada pelo `./install.sh` |
| `grill-me` | repositório `mattpocock/skills` (clonar, ler e copiar a pasta `grill-me` e o `LICENSE`) | MIT | a instalar; pasta exata dentro do repositório: a confirmar |
| `scroll-craft` | `nateherkai/scroll-craft`, plugin `nateherk-design`, pasta `plugins/nateherk-design/skills/scroll-craft/` | MIT | a instalar; usa Node e, para gerar mídia, uma chave kie.ai (opcional) |
| `reverse-engineer-anything` | `morluto/rea` | MIT | só com necessidade real (seção 11) |

Regra: clonar numa pasta nova, ler o conteúdo antes de copiar e copiar só a pasta da skill mais o `LICENSE`.

## 10. Flow pelo Chrome do dono (conector restrito)

Os agentes mexem no Flow usando o Chrome do dono, já logado, por um conector que só alcança `flow.google.com`, `labs.google`, o login do Google e arquivos de apoio do Google. Registrar no Linux:
```bash
URLS=(--allowedUrlPattern 'https://flow.google.com/*' --allowedUrlPattern 'https://labs.google/*' --allowedUrlPattern 'https://accounts.google.com/*' --allowedUrlPattern 'https://*.gstatic.com/*' --allowedUrlPattern 'https://*.googleusercontent.com/*' --allowedUrlPattern 'https://*.googleapis.com/*' --allowedUrlPattern 'https://www.google.com/recaptcha/*' --allowedUrlPattern 'about:blank')
claude mcp add --scope user flow-chrome -- npx -y chrome-devtools-mcp@1.11.0 --autoConnect --usageStatistics=false --redactNetworkHeaders=true "${URLS[@]}"
agy mcp add flow-chrome npx -y chrome-devtools-mcp@1.11.0 --autoConnect --usageStatistics=false --redactNetworkHeaders=true "${URLS[@]}"
```
No Windows: a forma com `cmd /c` e `MSYS_NO_PATHCONV=1` é **a confirmar**. O dono precisa abrir o Chrome, ativar a depuração remota em `chrome://inspect/#remote-debugging` e aceitar o aviso de permissão a cada conexão. **Ainda não foi testado** se o bloqueio de endereços vale para abas já abertas. Cada segundo de vídeo custa cerca de 3 créditos, e a skill `google-flow` manda perguntar antes de passar de 150 créditos.

## 11. Ferramentas externas avaliadas (não vêm instaladas)

- **REA (`rea-agents`, repositório `morluto/rea`):** ferramenta de engenharia reversa (~190 MB, um único mantenedor, projeto de 7 meses). Veredito da pesquisa: **instalar só com cuidados e só se houver uso real**. Não tem script de instalação, mas o `setup` altera `~/.claude.json` e a configuração do agy, e o servidor tem poder de executar código. Fixar a versão 6.9.0, rodar o `--dry-run` antes, fazer backup, não usar `--yes` sem ler o plano e, de preferência, instalar em ambiente isolado. A pesquisa não leu o código-fonte nem confirmou que não há telemetria, e o número de estrelas (468 mil em 7 meses) é atípico e não foi verificado. Confirmar com a empresa se engenharia reversa é permitida.
- **`grill-me` (`mattpocock/skills`): instalar.** Mantenedor conhecido (conta de 2017, educador de TypeScript), licença MIT, commit de 18/11/2026. É só texto de prompt, sem script, sem instalação automática e sem tocar em configuração. Único cuidado: sessões muito longas gastam contexto e cota. Fixar uma tag ou commit se quiser controle.
- **`scroll-craft` (`nateherkai/scroll-craft`): instalar com cuidados.** MIT, mantido por uma conta individual de 10 meses, 5,2 mil estrelas, último commit de 30/09/2026 (v0.3.1). Não tem `postinstall` e não altera configuração do Claude. Cuidados: fixar a tag `v0.3.1` em vez de seguir a `main`; **não usar o `kie.mjs`** com material confidencial, porque ele envia imagens e prompts para um serviço externo (kie.ai) e procura arquivos `.env` para achar a chave `KIE_AI_API_KEY`; não deixar `.env` com segredos da empresa na pasta de trabalho; instalar FFmpeg e navegadores pelo gerenciador do sistema. A skill manda o agente rodar utilitários Node e ferramentas locais com os seus privilégios. Pesquisa feita pelo `agy` e **não verificada por mim linha a linha**.

## 12. Prompt de instalação para o Claude do trabalho

Em `docs/prompt-instalacao.md` está o prompt revisado para outro Claude configurar o ambiente com aprovação do dono, bloco por bloco. As regras específicas do projeto da empresa **não** estão no repositório: o dono deve fornecê-las na própria conta empresarial.
