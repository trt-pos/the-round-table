#!/bin/bash 

SERVER="TheRoundTableServer"

rm -rf "TheRoundTableServer"

mkdir -p "$SERVER"

mkdir "$SERVER/app"
mkdir "$SERVER/downloads"

cp -r "desktop-app/plugins" "$SERVER"

(
  cd desktop-app || exit
  mvn package
)

cp "desktop-app/bin/desktop-app.jar" "$SERVER/downloads"
cp "desktop-app/installer.sh" "$SERVER/downloads"
cp "theroundtable-linux-x64.zip" "$SERVER/downloads"

cargo build --release -p server_side --bin server_side
cp "target/release/server_side" "$SERVER/app"

# Extracting plugins Data
JSON_NAME="pluginData.json"
cd "$SERVER/plugins" || exit
counter=1

# Loop a través de todos los archivos .jar en el directorio
for jar_file in *.jar; do
  json_path=$(unzip -l "$jar_file" | grep "$JSON_NAME" | awk '{print $4}')
  
  if [ -n "$json_path" ]; then
    unzip -p "$jar_file" "$json_path" > "$jar_file.json"
    echo "Extraído $JSON_NAME de $jar_file como $jar_file.json"
    counter=$((counter + 1))
  else
    echo "El archivo $jar_file no contiene $JSON_NAME"
  fi
done