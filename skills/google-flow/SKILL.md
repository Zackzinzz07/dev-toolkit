---
name: google-flow
description: Use para gerar vídeos no Google Flow (flow.google.com) cena por cena com o navegador dos agentes. Cobre login, créditos, estender cenas, duração, download e os limites de gasto. Use quando o usuário pedir para criar, continuar ou baixar um vídeo no Flow.
---

# Google Flow, operado por agente

## Antes de começar
- Use **somente** o servidor de navegador `flow-browser` (perfil dedicado, restrito a flow.google.com e ao login do Google). Nunca use o Chrome pessoal do usuário.
- Entre na conta certa. O menu da conta (avatar, canto superior direito) mostra o e-mail e os **créditos**. Se o login pedir senha ou código, **pare e peça ao usuário**; nunca digite senha nem tente contornar.
- Confira os créditos antes de gerar. Cada segundo de vídeo custa cerca de 3 créditos (4 s = 12, 6 s = 18, 8 s = 24, 10 s = 30).
- **Teto de gasto: pergunte antes de passar de 150 créditos numa sessão.** Não compre plano, upgrade nem créditos.

## Fluxo de uma cena
1. Abra o projeto (`flow.google.com/project/ID/edit/ID`). Se vier 404, a conta está errada: o projeto pertence a outra conta Google.
2. Clique no tempo da linha do tempo, **longe das pontas do clipe**. Com o marcador nas pontas o botão fica bloqueado ("Afaste o marcador das pontas do clipe").
3. Botão **Adicionar clipe** e depois **Estender**. Estender continua do último quadro, o que mantém o personagem.
   Se "Estender" estiver desabilitado, ou a conta está sem créditos ("Alerta de créditos insuficientes"), ou o vídeo passou do limite de edição (10 s em algumas contas, 15 s em outras). Pare e avise.
4. Escreva o prompt na caixa "Qual é a próxima etapa?". **Repita a descrição completa do personagem e do vilão em toda cena**, em um parágrafo, de preferência até ~800 caracteres, em português, sem texto nem logotipo na imagem.
5. Ajuste a duração no botão de segundos (controle deslizante de 3 a 10 s). Com o teclado: setas para mudar de 1 em 1 e `End` para o máximo. Feche o controle e confira o custo mostrado ("usar N créditos").
6. Clique em **Iniciar geração**. Espere a barra de progresso (%) sumir. **Confira a duração total subir** antes de dizer que terminou. Se não subiu, não terminou.
7. Assista a pelo menos um quadro do resultado (captura de tela ou frame). Se o herói ou o cenário mudou, refaça a cena.

## Baixar e entregar
- **Baixar mídia**: `720p Tamanho original` (MP4 com som) ou `270p GIF`. O arquivo cai na pasta de downloads do navegador do agente.
- Confira com `ffprobe` a duração, a resolução e se tem áudio. Extraia um quadro do fim com `ffmpeg` e olhe.
- Enviar o arquivo a uma pessoa é decisão do usuário: só envie se ele pediu e disse para quem.

## Cuidados
- Um único navegador por vez: o perfil não pode ser aberto por dois agentes juntos.
- Cada tentativa gasta créditos. Antes de refazer, diga por que a anterior falhou.
- Regras de conteúdo do Flow: se uma cena for recusada, reescreva sem tentar enganar o filtro e avise o usuário.
