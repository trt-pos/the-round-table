#!/bin/bash

PLUGIN_NAME=$1

bash build-plugins.sh "$PLUGIN_NAME"

mkdir "$HOME/.round-table-dev/plugins"
cp -r desktop-app/plugins/* ~/.round-table-dev/plugins/

rm -rf desktop-app/plugins