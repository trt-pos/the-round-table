#!/bin/bash
set -u

PLUGIN_NAME=$1

bash build-plugins.sh "$PLUGIN_NAME"

mkdir "$HOME/.round-table-dev/plugins"
cp -r output/plugins/* ~/.round-table-dev/plugins/

rm -rf desktop-app/plugins