#!/bin/bash
set -u

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
if [[ "$PLUGIN_NAME" != "all" ]]; then
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