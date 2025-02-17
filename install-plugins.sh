#!/bin/bash

bash build-plugins.sh

mkdir "$HOME/.round-table-dev/plugins"
cp -r desktop-app/plugins/* ~/.round-table-dev/plugins/

rm -rf desktop-app/plugins