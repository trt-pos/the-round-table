#!/bin/bash 
set -u

OUTPUT="$(pwd)/output"
rm -rf "$OUTPUT"
mkdir -p "$OUTPUT"

# Building the server side binary
SERVER_OUTPUT="$OUTPUT/trt-server-side"

mkdir -p "$SERVER_OUTPUT"
mkdir "$SERVER_OUTPUT/app"
mkdir "$SERVER_OUTPUT/downloads"
mkdir "$SERVER_OUTPUT/plugins"

cp "desktop-app/installer.sh" "$SERVER_OUTPUT/downloads"

(
  cd server-side || exit
  cargo build --release -p server_side --bin server_side
  mv "target/release/server_side" "$SERVER_OUTPUT/app"
)

# Building the desktop app
(
  cd desktop-app || exit
  bash build.sh all
)

cp -r "desktop-app/output/theroundtable-linux-x64" "$OUTPUT"
cp -r "desktop-app/output/theroundtable-windows-x64" "$OUTPUT"
  
(
  cd "output" || exit
  
  cp "theroundtable-windows-x64/bin/desktop-app.jar" "$SERVER_OUTPUT/downloads"
  cp "theroundtable-linux-x64/bin/desktop-app.jar" "$SERVER_OUTPUT/downloads"
  
  zip -r -9 "theroundtable-windows-x64.zip" "theroundtable-windows-x64" &
  zip -r -9 "theroundtable-linux-x64.zip" "theroundtable-linux-x64" &
  wait 
  
  cp "theroundtable-windows-x64.zip" "$SERVER_OUTPUT/downloads"
  cp "theroundtable-linux-x64.zip" "$SERVER_OUTPUT/downloads"
  
  rm "theroundtable-windows-x64.zip"
  rm "theroundtable-linux-x64.zip"
)

# Copying the plugins to the server
bash build-plugins.sh all
cp -r "output/plugins" "$SERVER_OUTPUT"

# Extracting plugins Data
(
  JSON_NAME="pluginData.json"
  cd "$SERVER_OUTPUT/plugins" || exit
  
  # Loop a través de todos los archivos .jar en el directorio
  for jar_file in *.jar; do
    json_path=$(unzip -l "$jar_file" | grep "$JSON_NAME" | awk '{print $4}')
    
    if [ -n "$json_path" ]; then
      unzip -p "$jar_file" "$json_path" > "$jar_file.json"
      echo "Extracted $JSON_NAME of $jar_file as $jar_file.json"
    else
      echo "The JAR $jar_file doesn't have $JSON_NAME"
    fi
  done
)