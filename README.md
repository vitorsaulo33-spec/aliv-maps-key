# Chave do Google Maps — ALIV Hub

Gera a chave do Google Maps que o [ALIV Hub](https://alivhub.com.br) usa para
calcular a distância da entrega, **dentro da conta Google do próprio lojista**.

## Para o lojista

Clique no botão abaixo. Abre um terminal no seu navegador, já conectado à sua
conta Google — não precisa instalar nada.

[![Abrir no Google Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/vitorsaulo33-spec/aliv-maps-key&cloudshell_tutorial=tutorial.md&cloudshell_print=COMECE_AQUI.txt)

Um passo a passo aparece do lado do terminal.

> **Importante:** nada roda sozinho. Depois que abrir, digite no terminal
> `bash setup.sh` e aperte ENTER — o aviso com esse comando aparece impresso
> no próprio terminal assim que a página carrega.

## O que o script faz

1. Cria (ou reaproveita) um projeto no Google Cloud da sua conta
2. Confere o faturamento — e mostra o link certo se faltar cadastrar o cartão
3. Ativa as APIs: Geocoding, Maps JavaScript, Places e Distance Matrix
4. Cria a chave **já restrita a essas APIs**
5. Opcionalmente entrega a chave direto no painel do ALIV Hub, via código de
   pareamento de uso único (sem copiar e colar)

## Perguntas comuns

**A ALIV vê meu cartão?** Não. O projeto, o faturamento e a chave ficam na sua
conta Google. A ALIV só recebe a chave — e só se você usar o código de
pareamento ou colar no painel.

**Tem custo?** O Google cobra pelo uso do mapa e mantém uma cota mensal
gratuita que cobre a maioria das operações. Você acompanha o consumo no painel
de métricas que o script mostra no final.

**Por que a chave não tem restrição de site ou de IP?** Porque a mesma chave é
usada pelo servidor (calcular o frete) e pelo navegador (desenhar o mapa) —
travar por um dos dois quebraria o outro. A proteção aqui é por API: mesmo
copiada, a chave só serve para os serviços de mapa.

**O mapa parou de funcionar depois de meses.** Quase sempre é o cartão da conta
Google que falhou e o Google desligou o faturamento. Reative em
[console.cloud.google.com/billing](https://console.cloud.google.com/billing).
