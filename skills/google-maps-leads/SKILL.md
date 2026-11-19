---
name: google-maps-leads
description: Use quando o usuário pedir dados públicos de uma loja ou empresa (nome, endereço, CEP, telefone, site, horário, fotos, nota) para montar landing page ou ficha de lead. Escolhe entre a Places API oficial do Google (preferida) e o scraper local do Google Maps (poucas lojas, uma já escolhida como lead). Não serve para varrer cidade ou montar lista de contatos em massa.
---

# Google Maps leads

Objetivo: juntar os dados públicos de **uma loja já escolhida como lead** para preencher uma landing page. Não é para varrer a cidade.

## 1. Antes de começar
- **Conta certa.** Prospecção de cliente e landing de projeto pessoal só em conta de escopo `pessoal`. Em conta `empresa` (por exemplo `claude-work`) **não use esta skill**. Se não souber o escopo da conta atual, pergunte.
- **Quantidade.** No máximo 15 buscas por rodada, uma loja por vez de preferência.
- Dado de contato público (telefone, endereço, site da loja) serve para a landing. **Não envie mensagem** a ninguém com ele sem autorização clara do usuário.

## 2. Qual caminho usar (nesta ordem)
1. **Places API (New), oficial.** Caminho preferido: sem risco de bloqueio e dentro dos termos do Google. Precisa de uma chave de API do Google Cloud. Peça a chave ao usuário na hora de usar, por variável de ambiente, e **nunca grave a chave em arquivo, memória, log ou repositório**. Endpoint de busca por texto: `POST https://places.googleapis.com/v1/places:searchText` com os cabeçalhos `X-Goog-Api-Key` e `X-Goog-FieldMask` (peça só os campos que a landing precisa).
2. **Scraper local** (`gosom/google-maps-scraper`, MIT), quando o usuário não tem chave e são poucas lojas. Risco: o Google pode bloquear o IP ou a conta, e a coleta automática vai contra os termos do Google Maps. Avise o usuário disso antes de rodar.
3. Dado nenhum disponível: peça ao usuário. Não invente endereço, telefone nem horário.

## 3. Usar o scraper local
Os scripts ficam em `ferramentas/maps/` do repositório `dev-toolkit`. Rode pelo Git Bash, a partir da pasta onde você clonou o repositório.

```bash
cd dev-toolkit/ferramentas/maps
./instalar-scraper.sh                      # só na primeira vez: baixa o binário do sistema (Windows .exe)
./buscar-lojas.sh "Nome da loja Cidade"  # até 15 buscas por rodada
```
- O resultado vai para `ferramentas/maps/mapas-saida/` (pasta fora do Git): um `.json` bruto e um `.landing.json` com os campos da landing (nome, categoria, endereço, CEP, telefone, site, e-mail, latitude e longitude, link do mapa, horário, nota, fotos).
- O script segue devagar de propósito (uma tarefa por vez). Não aumente a concorrência.
- Na primeira busca o scraper baixa um navegador sozinho. Pode demorar.

## 4. Depois da coleta
- Confira os dados com o usuário: nome certo, endereço certo, telefone certo, loja ainda aberta.
- O `.landing.json` já lista o que falta pedir ao dono da loja: CNPJ, logo, produtos e preços, texto sobre a loja. Peça esses itens, não os invente.
- Fotos do Maps são de terceiros: confirme com o dono da loja antes de publicar.
- Apague os arquivos de `mapas-saida/` quando o trabalho acabar. Eles têm dado de terceiros.
