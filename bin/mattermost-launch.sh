#!/bin/bash -x

DB_HOST=${DB_HOST:-db}
DB_PORT_3306_TCP_PORT=${DB_PORT_3306_TCP_PORT:-3306}
MM_USERNAME=${MYSQL_USER:-mmuser}
MM_PASSWORD=${MYSQL_PASSWORD:-mostest}
MM_DBNAME=${MYSQL_DATABASE:-mattermost_test}

env

if [ -n "$DATABASE_SERVICE_NAME" ]; then
echo -ne "Configure MySQL database connection..."
DB_SERVICE_NAME=$(echo ${DATABASE_SERVICE_NAME^^} | tr '-' '_')
sed -i "s@mmuser:mostest\@tcp(dockerhost:3306)\/mattermost_test@${MM_USERNAME}:${MM_PASSWORD}\@tcp($(printenv $(printenv DB_SERVICE_NAME)_SERVICE_HOST):$(printenv $(printenv DB_SERVICE_NAME)_SERVICE_PORT))\/${MM_DBNAME}@g" ${APP_ROOT}/config/config.json
grep tcp ${APP_ROOT}/config/config.json
fi

exec ${APP_ROOT}/bin/platform