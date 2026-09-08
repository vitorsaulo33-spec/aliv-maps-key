# Chave do Google Maps — ALIV Hub

<walkthrough-tutorial-duration duration="5"></walkthrough-tutorial-duration>

## O que vamos fazer aqui

O ALIV Hub usa o Google Maps para **calcular a distância da entrega** e cobrar
o frete certo. Sem essa chave, o cliente não consegue fechar o pedido no seu
app — ele trava na tela do endereço.

Esta chave fica **na sua conta Google**, no seu nome. A ALIV não tem acesso ao
seu cartão nem cobra nada por isso: você paga direto ao Google, e o Google tem
uma cota mensal gratuita que cobre a maioria das pizzarias.

São **3 cliques**. Clique em **Próximo** para começar.

## Passo 1 — Rodar o script

Clique no botão abaixo. Ele vai colar o comando no terminal (a tela preta do
lado direito). Depois é só apertar **Enter**.

```bash
bash setup.sh
```

<walkthrough-editor-open-file filePath="setup.sh">
    Ver o que o script faz (opcional)
</walkthrough-editor-open-file>

Na primeira vez, o Google vai pedir uma autorização (**Authorize**) — pode
aceitar: é ele confirmando que você deixa o script criar as coisas na sua conta.

Clique em **Próximo** enquanto ele roda.

## Passo 2 — Se pedir o cartão

Se aparecer a mensagem **"Você ainda não tem uma conta de faturamento"**, é o
único passo manual — o Google não deixa nenhum script cadastrar cartão.

1. Abra: [console.cloud.google.com/billing/create](https://console.cloud.google.com/billing/create)
2. Cadastre seu cartão (o Google costuma dar crédito grátis de teste)
3. Volte a esta janela e rode de novo:

```bash
bash setup.sh
```

Se **não** apareceu essa mensagem, pule este passo — está tudo certo.

## Passo 3 — Levar a chave para o ALIV Hub

Quando terminar, o script mostra a sua chave numa caixa verde.

**Jeito automático (recomendado):** no ALIV Hub, vá em
**Configurações → Traqueamento** e clique em **"Conectar chave do Google"**.
Vai aparecer um código de 6 letras. Cole esse código no terminal quando o
script pedir — a chave entra sozinha na sua loja, já testada.

**Jeito manual:** copie a chave da caixa verde e cole em
**Configurações → Traqueamento → Google Maps API**.

## Pronto!

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

Sua chave está ativa. Duas coisas para guardar:

**Onde ver o consumo:** o script mostrou no final um link do painel de métricas
do Google — lá você acompanha quanto está usando.

**Se um dia o mapa parar:** quase sempre é o cartão da conta Google que falhou e
o Google desligou o faturamento. O ALIV Hub avisa no painel quando detecta isso,
e o conserto é reativar o faturamento no Google Cloud.

Qualquer dúvida, chame o suporte da ALIV.
