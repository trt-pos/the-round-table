#!/bin/bash
set -u

SCRIPT_DIR="$(pwd)"

# Determinar el remote host. Si pasa como parametro produccion, se conecta al servidor de produccion, sino, se conecta al servidor de desarrollo
if [ "$1" == "prod" ]; then
  echo "Deploying to production"
  REMOTE_HOST="trt.lebastudios.org"
  git add .
  git commit -m "deploying actual submodules to production"
  git push origin master
else
  echo "Deploying to development"
  REMOTE_HOST="test-trt.lebastudios.org"
fi

REMOTE_USER="root"
REMOTE_DIR="/srv/the-round-table-api"

ssh "$REMOTE_USER@$REMOTE_HOST" "systemctl stop the-round-table"

scp -r "$SCRIPT_DIR/output/trt-server-side/app" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"
scp -r "$SCRIPT_DIR/output/trt-server-side/downloads" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"
scp -r "$SCRIPT_DIR/output/trt-server-side/plugins" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"

ssh "$REMOTE_USER@$REMOTE_HOST" "systemctl start the-round-table"