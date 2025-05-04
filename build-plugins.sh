#!/bin/bash
set -u

build-plugin() {
    PLUGIN_NAME=$1
    OUTPUT_DIR=$2
    
    (
      cd "plugin-$PLUGIN_NAME" || exit
      mvn clean package
      
      PLUGIN_JAR="$(basename "$PWD").jar"
      if [ -f "$PLUGIN_JAR" ]; then 
        mv "$PLUGIN_JAR" "$OUTPUT_DIR"
      fi
    )
}

# List of deployed plugins to build automatically when running this script with "all" as argument
plugins=(
    cash-register
    receipt-manager
    table-drawing
)

dev_plugins=(
    spanish-billing
    template
    accounting
)

PLUGINS_DIR="$(pwd)/output/plugins"
DEV_PLUGINS_DIR="$(pwd)/output/dev-plugins"

rm -rf "$PLUGINS_DIR"
rm -rf "$DEV_PLUGINS_DIR"

mkdir -p "$PLUGINS_DIR"
mkdir -p "$DEV_PLUGINS_DIR"

PLUGIN_NAME=$1

if [[ "$PLUGIN_NAME" != "all" && "$PLUGIN_NAME" != "dev" && "$PLUGIN_NAME" != "prod" ]]; then
    build-plugin "$PLUGIN_NAME" &
fi

if [ "$PLUGIN_NAME" == "prod" ] || [ "$PLUGIN_NAME" == "all" ]; then
    for plugin in "${plugins[@]}"; do
      build-plugin "$plugin" "$PLUGINS_DIR" &
    done
fi

if [ "$PLUGIN_NAME" == "dev" ] || [ "$PLUGIN_NAME" == "all" ]; then
    for plugin in "${dev_plugins[@]}"; do
      build-plugin "$plugin" "$DEV_PLUGINS_DIR" &
    done
fi

wait