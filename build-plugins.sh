#!/bin/bash
set -u

build-plugin() {
    PLUGIN_NAME=$1
    cd "plugin-$PLUGIN_NAME" || exit
    mvn clean package
    cd ..
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

PLUGIN_NAME=$1
if [[ "$PLUGIN_NAME" != "all" && "$PLUGIN_NAME" != "dev" ]]; then
    build-plugin "$PLUGIN_NAME" &
else
    for plugin in "${plugins[@]}"; do
      build-plugin "$plugin" &
    done
fi

if [ "$PLUGIN_NAME" == "dev" ]; then
    for plugin in "${dev_plugins[@]}"; do
      build-plugin "$plugin" &
    done
fi

wait

# Copy all the plugins into output/plugins
PLUGINS_DIR="$(pwd)/output/plugins"
rm -rf "$PLUGINS_DIR"
mkdir -p "$PLUGINS_DIR"

for dir in plugin-*/; do
  if [ -d "$dir" ]; then
    (
      cd "$dir" || exit
      PLUGIN_JAR="$(basename "$PWD").jar"
      if [ -f "$PLUGIN_JAR" ]; then  # Verifica si el archivo existe
        mv "$PLUGIN_JAR" "$PLUGINS_DIR"
      fi
    )
  fi
done