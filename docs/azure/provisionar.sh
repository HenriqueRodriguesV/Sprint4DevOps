#!/usr/bin/env bash
# =============================================================================
# Sprint 4 - Provisionamento dos recursos na Azure via Azure CLI
# Rodar no Azure Cloud Shell (Bash) ou em uma maquina com `az login` feito.
#
# Cria, nesta ordem:
#   1. Resource Group
#   2. Azure Database for MySQL Flexible Server + schema "ollipet" (banco em nuvem)
#   3. Regras de firewall (servicos do Azure + IP de quem roda o script)
#   4. App Service Plan (Linux, B1)
#   5. Web App (Linux, Java 21) com as App Settings do perfil "cloud"
#
# Uso:
#   export MYSQL_ADMIN_PASSWORD='<senha forte>'   # nunca versione a senha
#   bash docs/azure/provisionar.sh
# =============================================================================
set -euo pipefail

# ---------------------------------------------------------------------------
# Variaveis (os nomes precisam bater com o azure-pipelines.yml)
# ---------------------------------------------------------------------------
RM="${RM:-rm562917}"
LOCATION="${LOCATION:-mexicocentral}"   # regioes liberadas na Azure for Students: mexicocentral, chilecentral, eastus, southcentralus, northcentralus (MySQL B1ms so tem SKU em mexicocentral/chilecentral)
RESOURCE_GROUP_NAME="rg-ollipet-${RM}"

MYSQL_SERVER_NAME="mysql-ollipet-${RM}"
MYSQL_ADMIN_USER="ollipetadmin"
MYSQL_ADMIN_PASSWORD="${MYSQL_ADMIN_PASSWORD:?Defina MYSQL_ADMIN_PASSWORD antes de rodar (export MYSQL_ADMIN_PASSWORD=...)}"
MYSQL_DB_NAME="ollipet"

APP_SERVICE_PLAN="plan-ollipet-${RM}"
WEBAPP_NAME="ollipet-api-${RM}"         # mesmo valor de webAppName no azure-pipelines.yml
RUNTIME="JAVA:21-java21"

DATABASE_URL="jdbc:mysql://${MYSQL_SERVER_NAME}.mysql.database.azure.com:3306/${MYSQL_DB_NAME}?useSSL=true&requireSSL=true&serverTimezone=UTC"

echo ">> 1/5 Resource Group: ${RESOURCE_GROUP_NAME} (${LOCATION})"
az group create \
  --name "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION" \
  --output table

echo ">> 2/5 Azure Database for MySQL Flexible Server: ${MYSQL_SERVER_NAME}"
# Rodar de novo o script e seguro: o servidor so e criado se ainda nao existir.
if ! az mysql flexible-server show --resource-group "$RESOURCE_GROUP_NAME" --name "$MYSQL_SERVER_NAME" --output none 2>/dev/null; then
  az mysql flexible-server create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$MYSQL_SERVER_NAME" \
    --location "$LOCATION" \
    --admin-user "$MYSQL_ADMIN_USER" \
    --admin-password "$MYSQL_ADMIN_PASSWORD" \
    --sku-name Standard_B1ms \
    --tier Burstable \
    --storage-size 32 \
    --version 8.0.21 \
    --public-access None \
    --yes \
    --output none
fi

az mysql flexible-server db create \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --server-name "$MYSQL_SERVER_NAME" \
  --database-name "$MYSQL_DB_NAME" \
  --output table

echo ">> 3/5 Firewall do MySQL"
# 0.0.0.0 - 0.0.0.0 e a regra especial "permitir servicos do Azure" (o Web App).
az mysql flexible-server firewall-rule create \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --name "$MYSQL_SERVER_NAME" \
  --rule-name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0 \
  --output table

# IP de quem esta rodando o script: permite o SELECT direto no banco (video/CRUD).
MEU_IP="$(curl -s https://api.ipify.org || true)"
if [[ -n "$MEU_IP" ]]; then
  az mysql flexible-server firewall-rule create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$MYSQL_SERVER_NAME" \
    --rule-name AllowMeuIP \
    --start-ip-address "$MEU_IP" \
    --end-ip-address "$MEU_IP" \
    --output table
fi

echo ">> 4/5 App Service Plan (Linux): ${APP_SERVICE_PLAN}"
az appservice plan create \
  --name "$APP_SERVICE_PLAN" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION" \
  --sku B1 \
  --is-linux \
  --query "{nome:name, local:location, sku:sku.name, estado:status}" \
  --output table

echo ">> 5/5 Web App (Java 21): ${WEBAPP_NAME}"
az webapp create \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --plan "$APP_SERVICE_PLAN" \
  --runtime "$RUNTIME" \
  --query "{nome:name, host:defaultHostName, estado:state}" \
  --output table

# Always On: o Web App nao "dorme" sem trafego (evita a primeira chamada lenta).
az webapp config set \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --always-on true \
  --output none

az webapp config appsettings set \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --settings \
    SPRING_PROFILES_ACTIVE="cloud" \
    SERVER_PORT="8080" \
    WEBSITES_PORT="8080" \
    DATABASE_URL="$DATABASE_URL" \
    DATASOURCE_USERNAME="$MYSQL_ADMIN_USER" \
    DATASOURCE_PASSWORD="$MYSQL_ADMIN_PASSWORD" \
  --output none

echo
echo "================================================================"
echo " Recursos criados:"
az resource list --resource-group "$RESOURCE_GROUP_NAME" --output table
echo
echo " URL da API:     https://${WEBAPP_NAME}.azurewebsites.net/swagger-ui.html"
echo " Host do MySQL:  ${MYSQL_SERVER_NAME}.mysql.database.azure.com"
echo
echo " Valores para o Variable Group 'ollipet-cloud' (marque os 3 como secret):"
echo "   DATABASE_URL        = ${DATABASE_URL}"
echo "   DATASOURCE_USERNAME = ${MYSQL_ADMIN_USER}"
echo "   DATASOURCE_PASSWORD = (a senha que voce exportou)"
echo "================================================================"
