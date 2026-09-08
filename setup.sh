#!/usr/bin/env bash
# =============================================================================
#  ALIV HUB — Gerador da Chave do Google Maps
#
#  Roda no Google Cloud Shell, DENTRO da conta Google do próprio lojista:
#  o projeto, o faturamento e a chave são dele. A ALIV nunca vê o cartão.
#
#  O que este script faz sozinho:
#    1. escolhe (ou cria) o projeto no Google Cloud
#    2. confere se o faturamento está ligado — e ensina a ligar se não estiver
#    3. ativa as APIs que o ALIV Hub usa
#    4. cria a chave JÁ restrita a essas APIs
#    5. (opcional) entrega a chave direto no painel, sem copiar e colar
#
#  O que ele NÃO faz: cadastrar o cartão. O Google exige que isso seja feito
#  à mão, uma vez. O script detecta e mostra o link certo.
# =============================================================================
set -uo pipefail

PAINEL="${ALIV_PAINEL:-https://app.alivhub.com.br}"
PREFIXO_PROJETO="alivhub-maps"
NOME_CHAVE="ALIV Hub"

# APIs que o sistema usa. Geocoding é a que calcula distância/frete — sem ela
# o cliente não fecha pedido. As outras desenham o mapa e completam endereço.
# É esta lista que vira a RESTRIÇÃO da chave.
APIS=(
  geocoding-backend.googleapis.com
  maps-backend.googleapis.com
  places-backend.googleapis.com
  distance-matrix-backend.googleapis.com
)

# Precisa estar ligada para o próprio `api-keys create` funcionar — projeto
# novo vem com ela desligada e o comando falha com "API not enabled". NÃO
# entra na restrição da chave (a chave não fala com esta API, o gcloud fala).
API_CHAVES="apikeys.googleapis.com"

V=$'\e[32m'; A=$'\e[33m'; R=$'\e[31m'; N=$'\e[0m'; B=$'\e[1m'
ok()   { echo "${V}✔${N} $*"; }
info() { echo "${B}→${N} $*"; }
warn() { echo "${A}⚠${N} $*"; }
erro() { echo "${R}✘${N} $*"; }
titulo() { echo; echo "${B}════ $* ════${N}"; }

# --------------------------------------------------------------------------
titulo "1 de 5 — Conferindo sua conta Google"
CONTA=$(gcloud config get-value account 2>/dev/null)
if [[ -z "$CONTA" || "$CONTA" == "(unset)" ]]; then
  erro "Não consegui identificar sua conta Google. Feche e abra o Cloud Shell de novo."
  exit 1
fi
ok "Conectado como: ${B}${CONTA}${N}"
echo "  (a chave e a cobrança ficam nesta conta — confira se é a certa)"

# --------------------------------------------------------------------------
titulo "2 de 5 — Projeto no Google Cloud"
# Reaproveita um projeto nosso, se já existir: evita o lojista acumular
# projeto novo a cada vez que roda o script.
PROJETO=$(gcloud projects list --filter="projectId:${PREFIXO_PROJETO}-*" \
          --format="value(projectId)" --limit=1 2>/dev/null | head -1)

if [[ -n "$PROJETO" ]]; then
  ok "Já existe um projeto do ALIV Hub: ${B}${PROJETO}${N} — vou usar esse."
else
  PROJETO="${PREFIXO_PROJETO}-$(date +%s | tail -c 6)$RANDOM"
  PROJETO="${PROJETO:0:30}"
  info "Criando o projeto ${B}${PROJETO}${N}…"
  if ! gcloud projects create "$PROJETO" --name="ALIV Hub Maps" --quiet 2>/tmp/aliv_err; then
    erro "Não consegui criar o projeto:"
    sed 's/^/     /' /tmp/aliv_err
    echo
    echo "  Isso costuma ser limite de projetos da conta. Você pode:"
    echo "   • apagar um projeto que não usa em https://console.cloud.google.com/cloud-resource-manager"
    echo "   • ou rodar de novo escolhendo um projeto existente com:"
    echo "       gcloud config set project SEU_PROJETO && bash setup.sh"
    exit 1
  fi
  ok "Projeto criado."
fi
gcloud config set project "$PROJETO" --quiet >/dev/null 2>&1

# --------------------------------------------------------------------------
titulo "3 de 5 — Faturamento (a parte que precisa de você)"
FATURA_OK=$(gcloud billing projects describe "$PROJETO" \
            --format="value(billingEnabled)" 2>/dev/null)

if [[ "$FATURA_OK" != "True" ]]; then
  CONTAS=$(gcloud billing accounts list --filter="open=true" \
           --format="value(name)" 2>/dev/null)
  if [[ -z "$CONTAS" ]]; then
    warn "Você ainda não tem uma conta de faturamento no Google."
    echo
    echo "  ${B}Faça só isto (uma vez, leva 2 minutos):${N}"
    echo "   1. Abra: ${B}https://console.cloud.google.com/billing/create${N}"
    echo "   2. Cadastre seu cartão (o Google costuma dar crédito grátis de teste)"
    echo "   3. Volte aqui e rode de novo:  ${B}bash setup.sh${N}"
    echo
    echo "  Por que precisa: o Google exige cartão para liberar o mapa, mesmo"
    echo "  dentro da cota gratuita. A cobrança é da sua conta, direto com o Google."
    exit 2
  fi
  # `list` devolve "billingAccounts/0X0X0X-...", mas o --billing-account quer
  # só o ID. Passar o caminho completo faz o link falhar sem explicar.
  CONTA_FAT=$(echo "$CONTAS" | head -1 | sed 's#^billingAccounts/##')
  info "Vinculando o projeto à sua conta de faturamento…"
  if gcloud billing projects link "$PROJETO" --billing-account="$CONTA_FAT" --quiet >/dev/null 2>&1; then
    ok "Faturamento vinculado."
  else
    erro "Não consegui vincular o faturamento."
    echo "  Faça manualmente: https://console.cloud.google.com/billing/linkedaccount?project=${PROJETO}"
    echo "  Depois rode de novo: bash setup.sh"
    exit 2
  fi
else
  ok "Faturamento já está ativo neste projeto."
fi

# --------------------------------------------------------------------------
titulo "4 de 5 — Ativando as APIs do mapa"
info "Isso leva de 30 a 60 segundos, pode deixar rodando…"
if gcloud services enable "${APIS[@]}" "$API_CHAVES" --project="$PROJETO" --quiet 2>/tmp/aliv_err; then
  ok "APIs ativadas: Geocoding, Maps JavaScript, Places e Distance Matrix."
else
  erro "Falha ao ativar as APIs:"
  sed 's/^/     /' /tmp/aliv_err
  exit 1
fi

# --------------------------------------------------------------------------
titulo "5 de 5 — Criando a chave"
# Reaproveita a chave do ALIV se já existir (rodar duas vezes não vira bagunça).
CHAVE_ID=$(gcloud services api-keys list --project="$PROJETO" \
           --filter="displayName:'${NOME_CHAVE}'" \
           --format="value(name)" --limit=1 2>/dev/null | head -1)

if [[ -n "$CHAVE_ID" ]]; then
  ok "Você já tinha uma chave do ALIV Hub — vou reaproveitar."
else
  ALVOS=()
  for api in "${APIS[@]}"; do ALVOS+=(--api-target="service=${api}"); done
  # SEM restrição de IP ou de site, de propósito: a mesma chave é usada pelo
  # SERVIDOR (calcular frete) e pelo NAVEGADOR (desenhar o mapa) — restringir
  # por um dos dois quebraria o outro. A trava aqui é por API: mesmo que alguém
  # copie a chave, ela só serve para mapa, nada mais.
  CHAVE_ID=$(gcloud services api-keys create \
              --display-name="${NOME_CHAVE}" \
              "${ALVOS[@]}" \
              --project="$PROJETO" \
              --format="value(response.name)" --quiet 2>/tmp/aliv_err)
  if [[ -z "$CHAVE_ID" ]]; then
    erro "Não consegui criar a chave:"
    sed 's/^/     /' /tmp/aliv_err
    exit 1
  fi
  ok "Chave criada e restrita às APIs do mapa."
fi

CHAVE=$(gcloud services api-keys get-key-string "$CHAVE_ID" \
        --format="value(keyString)" --quiet 2>/dev/null)
if [[ -z "$CHAVE" ]]; then
  erro "A chave foi criada, mas não consegui ler o valor dela."
  echo "  Pegue manualmente em: https://console.cloud.google.com/apis/credentials?project=${PROJETO}"
  exit 1
fi

echo
echo "${V}${B}╔══════════════════════════════════════════════════════════════╗${N}"
echo "${V}${B}║  SUA CHAVE DO GOOGLE MAPS ESTÁ PRONTA                        ║${N}"
echo "${V}${B}╚══════════════════════════════════════════════════════════════╝${N}"
echo
echo "   ${B}${CHAVE}${N}"
echo

# --------------------------------------------------------------------------
# Entrega automática no painel — evita o erro clássico de copiar pela metade.
echo "${B}Quer que eu já coloque essa chave na sua loja?${N}"
echo "  No ALIV Hub: Configurações → Traqueamento → botão ${B}\"Conectar chave do Google\"${N}"
echo "  Ele mostra um código de 6 letras. Cole aqui embaixo."
echo "  (ou aperte ENTER para pular e colar a chave no painel você mesmo)"
echo
read -r -p "  Código do painel: " CODIGO

if [[ -n "${CODIGO// /}" ]]; then
  CODIGO_LIMPO=$(echo "$CODIGO" | tr -d '[:space:]' | tr '[:lower:]' '[:upper:]')
  RESP=$(curl -s -m 25 -X POST "${PAINEL}/api/public/google-key/pair" \
         -H "Content-Type: application/json" \
         -d "{\"code\":\"${CODIGO_LIMPO}\",\"key\":\"${CHAVE}\"}" 2>/dev/null)
  if echo "$RESP" | grep -q '"success": *true'; then
    ok "Pronto! A chave já está ativa na sua loja — não precisa fazer mais nada."
  else
    MSG=$(echo "$RESP" | sed -n 's/.*"message": *"\([^"]*\)".*/\1/p')
    warn "Não consegui entregar a chave automaticamente${MSG:+: $MSG}"
    echo "  Sem problema: copie a chave acima e cole no painel em"
    echo "  Configurações → Traqueamento → Google Maps API."
  fi
else
  info "Beleza. Copie a chave acima e cole em Configurações → Traqueamento."
fi

echo
echo "${B}Guarde este endereço${N} — é onde você acompanha o consumo do mapa:"
echo "  https://console.cloud.google.com/google/maps-apis/metrics?project=${PROJETO}"
echo
echo "${A}Importante:${N} se o cartão da sua conta Google falhar, o Google desliga"
echo "o faturamento e o mapa para de funcionar (o pedido do cliente trava no"
echo "endereço). O ALIV Hub avisa você no painel quando isso acontece."
echo
