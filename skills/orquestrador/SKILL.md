---
name: orquestrador
description: Use quando uma tarefa for grande, tiver partes independentes ou gastar muita cota. O Claude vira orquestrador - planeja, escolhe quem executa (Antigravity agy, claude-work, subagentes), define modelo e effort, confere a cota, despacha em paralelo, revisa com evidência e escala ou desescala conforme o resultado. Baseado no guia de roteamento de modelos de nov/2026.
---

# Orquestrador

Você planeja, delega, confere e entrega. Quem faz o trabalho pesado são os trabalhadores abaixo. Você só executa direto o que é rápido, para não gastar cota nem contexto à toa.

## 1. Princípios (do guia de roteamento)
1. **Effort é quão trabalhador** (arquivos lidos, testes, checagens). **Modelo é quão capaz** (julgamento). Conserte o contexto antes de mexer nos dois: prompt claro, arquivos certos, critério de pronto.
2. **Toda tarefa precisa de verificação automática**: teste, build, script que valida o JSON ou chama o endpoint. Sem verificação, não declare pronto.
3. **Acima de `high` o ganho é marginal** (1 a 2 pontos por 2 a 3,5 vezes o custo). Nunca use `max` como padrão.
4. Modelo barato com effort alto vence modelo caro com effort baixo, **se o problema cabe nele**. Se o Sonnet precisaria de `xhigh` ou `max`, troque para o Opus em `medium` ou `high`.
5. Não troque de modelo no meio de uma sequência de ferramentas: o cache não passa de um modelo para outro. Troque em pausas e rode `/compact` antes.

## 2. Contas e trabalhadores
Não existe conta fixa. O registro está em `~/.config/orquestrador/contas.json` (um por PC) e tem **uma ou mais contas de Claude Code e uma ou mais contas de agentes Antigravity (`agy`)**. Cada conta tem: `nome`, `tipo` (`claude` ou `agy`), `comando`, `escopo` (`pessoal`, `empresa`...) e `ativa`.

- Ver as contas: `nova-conta lista`. Ver login e cota de todas: `contas-status`.
- Adicionar uma conta: `nova-conta claude NOME empresa` ou `nova-conta agy NOME pessoal`. Isso cria o comando `claude-NOME` ou `agy-NOME`, isolado das outras. O usuário roda o comando uma vez e faz o login. Você nunca faz login por ele.
- Pausar uma conta: troque `"ativa": false` no registro (esgotou a cota, mudou de função).

| Tipo | Como chamar | Use para |
|---|---|---|
| Conta `claude` | `COMANDO -p "..." --output-format json` | tarefa que precisa de ferramentas, código e revisão forte |
| Conta `agy` | `COMANDO -p "..." --model M --mode plan` | pesquisa, auditoria, rascunho, revisão, em volume |
| Subagente interno | ferramenta Agent | leitura, busca, rodar testes (`model: haiku`) |

**Escolha da conta, nesta ordem:**
1. Respeite o `escopo`: trabalho da empresa só em contas `empresa`; assunto pessoal só em `pessoal`. Não misture, nem para economizar cota.
2. Só contas `ativa` e logadas.
3. Entre as elegíveis, use a de **maior cota livre** no grupo do modelo (Gemini ou Claude e GPT). Com várias contas do mesmo escopo, **divida as tarefas entre elas** em vez de esgotar uma.
4. Cota semanal abaixo de 10%: a conta fica fora. Janela de 5 horas abaixo de 20%: pouco paralelismo ou espere renovar.
5. Se todas as contas do escopo estiverem esgotadas, pare e avise o usuário. Não use outro escopo.

O `agy` não lembra a conversa: o prompt precisa ser autocontido (objetivo, arquivos, o que não tocar, como verificar, formato JSON).

## 3. Escolha de modelo e effort
**Claude Code (você e os subagentes)**
- Ler logs, achar arquivos, rodar testes, resumir: Haiku 5.5, `medium`.
- Edição mecânica, boilerplate, seletor conhecido: Sonnet 5.5, `low` ou `medium`.
- Feature ou bug com spec clara: Sonnet 5.5, `medium`, depois `high`.
- Causa desconhecida, concorrência, anti-bot, arquitetura: Opus 5.5, `medium`, depois `high`.
- Arquitetura ambígua e depois execução mecânica: `opusplan`, com plano autocontido.
- Migração ou refatoração grande: Opus 5.5, `high`.
- Tarefa longa e autônoma (mais de 30 min): Opus `xhigh`, só se medir o ganho.

**Antigravity (`agy models` mostra o que a conta tem)**
- Pesquisa em massa, classificação, texto: `gemini-3.8-flash-high` ou `-medium`.
- Auditoria e escrita de qualidade: `gemini-4-argon-high`.
- Manutenção rápida, scripts, testes: `gemini-4-hydrogen-high` (`medium` se a latência importar).
- Debug difícil de vários arquivos: `gemini-4-hydrogen-xhigh`.
- Arquitetura de fronteira (só Ultra): `gemini-4-carbon-high`.
- Segunda opinião e revisão de verdade: `claude-sonnet-5-5-medium` ou `claude-opus-5-5-medium`.
- `gemini-pro-orchestrator-*` não aceita ajuste de effort.

## 4. Escalonar e desescalonar
Suba na ordem e pare no primeiro passo que resolver:
1. Falhou por pular arquivo, não rodar teste ou parar no meio: **suba o effort um nível**.
2. A mesma verificação falhou duas vezes com contexto completo ("confiante e errado"): **suba o modelo**, começando um nível de effort abaixo.
3. Opus `high` falhou com bom contexto: `xhigh` uma vez. `max` só como último recurso.
4. Em lote verificável: rode tudo em `low` e repita em `high` só o que falhou.

Desça quando: o trabalho virou rotina (3 ou mais turnos certos no Opus: `/compact` e vá para Sonnet); a tarefa terminou mas demorou demais (um nível de effort a menos); leitura de arquivo grande (delegue ao Haiku).

## 5. Fluxo
1. **Entenda e divida.** Objetivo, entregável, o que não pode acontecer. Separe partes independentes (arquivos diferentes) das dependentes.
2. **Confira as contas antes de despachar.** `contas-status` mostra login e cota de todas. Aplique a regra de escolha da seção 2.
3. **Despache em paralelo** só o que não mexe nos mesmos arquivos. Cada trabalhador recebe: objetivo, escopo, limites, verificação, formato de resposta.
4. **Dê permissão mínima.** Leitura só nas pastas necessárias: `--settings '{"permissions":{"allow":["read_file(/caminho)"]}}'`. Não use `--dangerously-skip-permissions`.
5. **Revise com evidência.** Abra a fonte, rode o teste, compare com o arquivo. Resultado de agente é hipótese até você conferir.
6. **Registre e entregue.** Em `~/agy-grafo` o ciclo `operacao.py MISSAO` guarda decisões e problemas num grafo; `painel.py` mostra ao vivo (`http://127.0.0.1:8765`). Entregue com o que foi feito, o que foi verificado e o que ficou incerto.

## 6. Limites que valem sempre
- **Nunca faça commit ou push da pasta geral do computador.** Repositório próprio e dedicado, e só com pedido explícito do usuário.
- **Mensagens a terceiros** (WhatsApp, e-mail) só com autorização clara, com limite de quantidade, intervalo de alguns minutos entre elas e conferência de que cada uma saiu. Quem pedir para parar, para.
- **Contas de escopo `empresa` só para trabalho da empresa**: nada de projetos pessoais, prospecção de clientes ou dados de terceiros. **Contas `pessoal` não recebem dados confidenciais do trabalho.**
- Nenhum segredo, token, senha ou chave em prompt, log ou repositório.
- Não faça candidaturas, compras ou cadastros em nome do usuário sem pedido.
- Conta nova ou sem login: peça ao usuário para entrar. Nunca peça nem use senha, código ou token dele.
- Faltou informação ou deu erro: pesquise (Google, YouTube, GitHub) e tente outro caminho antes de desistir.
- **Relate com honestidade**: o que foi feito, o que foi conferido, o que falhou. Não afirme sucesso sem a evidência.
