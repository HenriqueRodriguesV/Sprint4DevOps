#!/usr/bin/env bash
# Sprint 4 - provisionamento dos recursos na Azure via CLI (rodar no Cloud Shell).
# Cria: Resource Group, Azure Database for MySQL Flexible Server (banco em nuvem),
# App Service Plan (Linux) e Web App (Java 21), com as variaveis de ambiente que o
# application-cloud.properties espera.
set -euo pipefail

# ----------------------------------------------------------------------------
# Variaveis - troque RM000000 pelo seu RM e ajuste a senha do banco.
# ----------------------------------------------------------------------------
RM="RM562917"
RESOURCE_GROUP_NAME="rg-ollipet-${RM,,}"
LOCATION="brazilsouth"

MYSQL_SERVER_NAME="mysql-ollipet-${RM,,}"
MYSQL_ADMIN_USER="ollipetadmin"
MYSQL_ADMIN_PASSWORD='TrocarEstaSenha!123'   # troque antes de rodar
MYSQL_DB_NAME="ollipet"

APP_SERVICE_PLAN="plan-ollipet-${RM,,}"
WEBAPP_NAME="ollipet-api-${RM,,}"
RUNTIME="JAVA:21-java21"

echo ">> Resource Group"
az group create \
  --name "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION"

echo ">> Azure Database for MySQL Flexible Server (banco em nuvem - obrigatorio)"
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
  --public-access 0.0.0.0

echo ">> Criar o schema do projeto dentro do servidor MySQL"
az mysql flexible-server db create \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --server-name "$MYSQL_SERVER_NAME" \
  --database-name "$MYSQL_DB_NAME"

echo ">> Liberar acesso dos servicos do Azure (Web App) ao MySQL"
az mysql flexible-server firewall-rule create \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --name "$MYSQL_SERVER_NAME" \
  --rule-name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

echo ">> App Service Plan (Linux)"
az appservice plan create \
  --name "$APP_SERVICE_PLAN" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --location "$LOCATION" \
  --sku B1 \
  --is-linux

echo ">> Web App (Java 21)"
az webapp create \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --plan "$APP_SERVICE_PLAN" \
  --runtime "$RUNTIME"

echo ">> Variaveis de ambiente do Web App (perfil cloud do Spring)"
az webapp config appsettings set \
  --name "$WEBAPP_NAME" \
  --resource-group "$RESOURCE_GROUP_NAME" \
  --settings \
    SPRING_PROFILES_ACTIVE="cloud" \
    DATABASE_URL="jdbc:mysql://${MYSQL_SERVER_NAME}.mysql.database.azure.com:3306/${MYSQL_DB_NAME}?useSSL=true&requireSSL=true&serverTimezone=UTC" \
    DATASOURCE_USERNAME="${MYSQL_ADMIN_USER}" \
    DATASOURCE_PASSWORD="${MYSQL_ADMIN_PASSWORD}" \
    WEBSITES_PORT="8080"

echo ">> Pronto. URL da aplicacao:"
echo "https://${WEBAPP_NAME}.azurewebsites.net"
echo
echo "Use estes mesmos nomes (RESOURCE_GROUP_NAME, WEBAPP_NAME) ao criar o Service"
echo "Connection no Azure DevOps e ao preencher o Variable Group 'ollipet-cloud'."
