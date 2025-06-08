#!/bin/bash
set -u

build-plugin() {
    PLUGIN_NAME=$1
    OUTPUT_DIR=$2
    
    (
      cd "plugin-$PLUGIN_NAME" || exit
      mvn clean package
      
      PLUGIN_JAR="$(mvn help:evaluate -Dexpression=project.name -q -DforceStdout).jar"
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

if [[ "$PLUGIN_NAME" != "dev" && "$PLUGIN_NAME" != "prod" ]]; then
  
  if [[ "${plugins[*]}" == *"$PLUGIN_NAME"* ]]; then
    build-plugin "$PLUGIN_NAME" "$PLUGINS_DIR"
    exit 0
  fi
   
  if [[ "${dev_plugins[*]}" == *"$PLUGIN_NAME"* ]]; then
    build-plugin "$PLUGIN_NAME" "$DEV_PLUGINS_DIR"
    exit 0
  fi
  
  echo "Plugin not found. Please specify a plugin name or use 'prod' or 'dev' to build all plugins."
  exit 1
fi

if [ "$PLUGIN_NAME" == "prod" ] || [ "$PLUGIN_NAME" == "dev" ]; then
    for plugin in "${plugins[@]}"; do
      build-plugin "$plugin" "$PLUGINS_DIR" &
    done
fi

if [ "$PLUGIN_NAME" == "dev" ]; then
    for plugin in "${dev_plugins[@]}"; do
      build-plugin "$plugin" "$DEV_PLUGINS_DIR" &
    done
fi

wait