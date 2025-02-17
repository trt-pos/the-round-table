#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Determinar el remote host. Si pasa como parametro produccion, se conecta al servidor de produccion, sino, se conecta al servidor de desarrollo
if [ "$1" == "prod" ]; then
  echo "Deploying to production"
  REMOTE_HOST="trt.lebastudios.org"
else
  echo "Deploying to development"
  REMOTE_HOST="test-trt.lebastudios.org"
fi

REMOTE_USER="root"
REMOTE_DIR="/srv/the-round-table-api"

bash "$SCRIPT_DIR/build-plugins.sh"
bash "$SCRIPT_DIR/build-app.sh" "linux"
bash "$SCRIPT_DIR/build-server-api.sh"

ssh "$REMOTE_USER@$REMOTE_HOST" "systemctl stop the-round-table"

scp -r "$SCRIPT_DIR/TheRoundTableServer/app" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"
scp -r "$SCRIPT_DIR/TheRoundTableServer/downloads" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"
scp -r "$SCRIPT_DIR/TheRoundTableServer/plugins" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"

ssh "$REMOTE_USER@$REMOTE_HOST" "systemctl start the-round-table"