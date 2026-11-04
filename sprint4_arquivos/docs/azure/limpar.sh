#!/usr/bin/env bash
# Apaga todos os recursos criados por provisionar.sh, para nao gerar custo apos a entrega.
set -euo pipefail

RM="RM562917"
RESOURCE_GROUP_NAME="rg-ollipet-${RM,,}"

az group delete --name "$RESOURCE_GROUP_NAME" --yes --no-wait
echo "Exclusao do grupo de recursos '${RESOURCE_GROUP_NAME}' disparada (no-wait)."
