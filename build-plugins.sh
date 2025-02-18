#!/bin/bash

rm -rf "desktop-app/plugins"
mkdir -p "desktop-app/plugins"

cash-register() {
    cd "plugin-cash-register" || exit 
    mvn clean package
    cd ..
}

receipt-manager() {
    cd "plugin-receipt-manager" || exit
    mvn clean package 
    cd ..
}

table-drawing() {
    cd "plugin-table-drawing" || exit 
    mvn clean package 
    cd ..
}

spanish-billing() {
    cd "plugin-spanish-billing" || exit 
    mvn clean package
    cd ..
}

plugins=(
    cash-register
    receipt-manager
    table-drawing
    spanish-billing
)

PLUGIN_NAME=$1
if [[ -n "$PLUGIN_NAME" ]]; then
    if [[ ${plugins[@]} =~ "${PLUGIN_NAME}" ]]; then
        # Ejecutar solo el plugin especificado
        $PLUGIN_NAME
    else
        echo "Error: Plugin '$PLUGIN_NAME' not found"
        exit 1
    fi
else
    for plugin in "${plugins[@]}"; do
        $plugin &
    done
    wait
fi