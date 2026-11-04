#!/usr/bin/env bash
# Apaga TODOS os recursos criados por provisionar.sh (para nao gerar custo
# depois da avaliacao). Remove o Resource Group inteiro.
set -euo pipefail

RM="${RM:-rm562917}"
RESOURCE_GROUP_NAME="rg-ollipet-${RM}"

az group delete --name "$RESOURCE_GROUP_NAME" --yes --no-wait
echo "Exclusao do Resource Group '${RESOURCE_GROUP_NAME}' disparada."
echo "Acompanhe com: az group exists --name ${RESOURCE_GROUP_NAME}"
