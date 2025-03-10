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

PLUGIN_NAME=$1
if [[ "$PLUGIN_NAME" != "all" ]]; then
    build-plugin "$PLUGIN_NAME"
else
    for plugin in "${plugins[@]}"; do
      build-plugin "$plugin" &
    done
    wait
fi

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