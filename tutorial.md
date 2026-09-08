# Chave do Google Maps — ALIV Hub

<walkthrough-tutorial-duration duration="5"></walkthrough-tutorial-duration>

## Antes de tudo: rode o comando

Nada acontece sozinho aqui. **Você precisa rodar um comando no terminal** (a
tela preta embaixo). É o único comando de todo o processo.

Clique no ícone de copiar do quadro abaixo — ele cola o comando no terminal.
Depois **aperte ENTER**:

```bash
bash setup.sh
```

Se o Google pedir autorização (**Authorize**), pode aceitar: é ele confirmando
que você permite criar a chave na sua conta.

⚠️ **Só clique em "Próximo" depois que o comando estiver rodando.**

## O que o assistente está fazendo

Enquanto ele roda, o que está acontecendo:

1. criando um projeto no Google Cloud **da sua conta**
2. conferindo se o faturamento está ligado
3. ativando as APIs do mapa
4. criando a sua chave, já configurada

O ALIV Hub usa essa chave para **calcular a distância da entrega**. Sem ela, o
cliente trava na tela do endereço e não fecha o pedido.

A chave é sua, na sua conta. A ALIV não vê seu cartão nem cobra por isso.

## Se pedir o cartão

Se aparecer **"Você ainda não tem uma conta de faturamento"**, esse é o único
passo manual — o Google não deixa nenhum script cadastrar cartão.

1. Abra [console.cloud.google.com/billing/create](https://console.cloud.google.com/billing/create)
2. Cadastre seu cartão (o Google costuma dar crédito grátis de teste)
3. Volte aqui e rode de novo:

```bash
bash setup.sh
```

Se **não** apareceu essa mensagem, ignore este passo.

## Levar a chave para o ALIV Hub

Quando terminar, a sua chave aparece numa **caixa verde** no terminal.

**Jeito fácil:** no ALIV Hub, vá em **Configurações → Traqueamento** e clique
em **"Conectar chave do Google"**. Aparece um código de 6 letras. Cole esse
código no terminal quando o assistente pedir — a chave entra sozinha na sua
loja, já testada.

**Jeito manual:** copie a chave da caixa verde e cole em
**Configurações → Traqueamento → Google Maps API**.

## Pronto!

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

Se a caixa verde apareceu com a sua chave, terminou.

**Não apareceu nada?** Provavelmente o comando não chegou a rodar. Volte ao
primeiro passo, digite `bash setup.sh` no terminal e aperte ENTER.

**Deu "No such file or directory"?** Você abriu um terminal novo e ele começa
na pasta errada. Rode isto antes:

```bash
cd ~/cloudshell_open/aliv-maps-key* && bash setup.sh
```

**Se um dia o mapa parar de funcionar:** quase sempre é o cartão da conta
Google que falhou e o Google desligou o faturamento. O ALIV Hub avisa no painel
quando detecta isso.
