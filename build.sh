#!/bin/bash 
set -u

SERVER_OUTPUT="$(pwd)/output/trt-server-side"

# Preparing the output directory
rm -rf "$SERVER_OUTPUT"
mkdir -p "$SERVER_OUTPUT"
mkdir "$SERVER_OUTPUT/app"
mkdir "$SERVER_OUTPUT/downloads"
mkdir "$SERVER_OUTPUT/plugins"

# Building the server side binary
(
  cd server-side || exit
  cargo build --release -p server_side --bin server_side
  mv "target/release/server_side" "$SERVER_OUTPUT/app"
)

# Building the desktop app
cp "desktop-app/installer.sh" "$SERVER_OUTPUT/downloads"

bash build-app.sh linux
(
  cd "output" || exit
  cp "theroundtable-linux-x64/bin/desktop-app.jar" "$SERVER_OUTPUT/downloads"
  zip -r -9 "theroundtable-linux-x64.zip" "theroundtable-linux-x64"
  cp "theroundtable-linux-x64.zip" "$SERVER_OUTPUT/downloads"
  rm "theroundtable-linux-x64.zip"
)

# Copying the plugins to the server
bash build-plugins.sh all
cp -r "output/plugins" "$SERVER_OUTPUT"

# Extracting plugins Data
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