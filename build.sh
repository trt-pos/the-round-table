#!/bin/bash 

#######################################################################
# Checkout the production version of the project
#######################################################################
if [ "$1" == "prod" ]; then
    git submodule update --init --recursive
    # shellcheck disable=SC2016
    git submodule foreach --recursive 'git fetch --tags && git checkout $(git tag -l "v*" --sort=-v:refname | head -n1)'
fi

set -u

#######################################################################
# Cleaning up the output directory
#######################################################################
OUTPUT="$(pwd)/output"
rm -rf "$OUTPUT"
mkdir -p "$OUTPUT"

#######################################################################
# Building the central server and plugin repo
#######################################################################
SERVER_OUTPUT="$OUTPUT/trt-central"

mkdir -p "$SERVER_OUTPUT"
mkdir "$SERVER_OUTPUT/bin"
mkdir "$SERVER_OUTPUT/downloads"
mkdir "$SERVER_OUTPUT/plugins"

(
  cd trt-central || exit
  cargo build --release -p bin --bin bin &
  cargo build --release -p plugin-repo --bin plugin-repo &
  wait 
  cp "target/release/bin" "$SERVER_OUTPUT/bin/rest-api"
  cp "target/release/plugin-repo" "$SERVER_OUTPUT/bin/plugin-repo"
)

#######################################################################
# Building the desktop app
#######################################################################
(
  cd desktop-app || exit
  bash build.sh all
)

#######################################################################
# Copy the desktop app to the server file system
#######################################################################
cp -r desktop-app/output/* "$OUTPUT"
  
(
  cd "${OUTPUT}" || exit
  
  cp "theroundtable-windows-x64/bin/desktop-app.jar" "$SERVER_OUTPUT/downloads"
  cp "theroundtable-linux-x64/bin/desktop-app.jar" "$SERVER_OUTPUT/downloads"
  
  cp "theroundtable-windows-x64/start.exe" "$SERVER_OUTPUT/downloads/start-win-x64.bin"
  cp "theroundtable-linux-x64/start" "$SERVER_OUTPUT/downloads/start-linux-x64.bin"
  
  cp trt-installer-* "$SERVER_OUTPUT/downloads"
  mv "theroundtable-windows-x64.zip" "$SERVER_OUTPUT/downloads"
  mv "theroundtable-linux-x64.zip" "$SERVER_OUTPUT/downloads"
)

#######################################################################
# Add the jdk needed to create a portable version of the app
#######################################################################
## 24.0.1
# Linux x64: https://download.java.net/java/GA/jdk24.0.1/24a58e0e276943138bf3e963e6291ac2/9/GPL/openjdk-24.0.1_linux-x64_bin.tar.gz
# Windows x64: https://download.java.net/java/GA/jdk24.0.1/24a58e0e276943138bf3e963e6291ac2/9/GPL/openjdk-24.0.1_windows-x64_bin.zip
mkdir -p .jdks

(
  cd .jdks || exit
  
  if [ ! -d "openjdk-24.0.1_linux-x64_bin" ]; then
    wget https://download.java.net/java/GA/jdk24.0.1/24a58e0e276943138bf3e963e6291ac2/9/GPL/openjdk-24.0.1_linux-x64_bin.tar.gz
    tar -xzf openjdk-24.0.1_linux-x64_bin.tar.gz
    mv jdk-24.0.1 openjdk-24.0.1_linux-x64_bin
    rm -r openjdk-24.0.1_linux-x64_bin.tar.gz
  fi
  
  if [ ! -d "openjdk-24.0.1_windows-x64_bin" ]; then
    wget https://download.java.net/java/GA/jdk24.0.1/24a58e0e276943138bf3e963e6291ac2/9/GPL/openjdk-24.0.1_windows-x64_bin.zip
    unzip openjdk-24.0.1_windows-x64_bin.zip
    mv jdk-24.0.1 openjdk-24.0.1_windows-x64_bin
    rm -r openjdk-24.0.1_windows-x64_bin.zip
  fi
)

# Copy the jdks to the portable versions

mkdir -p "$OUTPUT/theroundtable-linux-x64/jdk"
mkdir -p "$OUTPUT/theroundtable-windows-x64/jdk"

cp -r .jdks/openjdk-24.0.1_linux-x64_bin/* "${OUTPUT}/theroundtable-linux-x64/jdk"
cp -r .jdks/openjdk-24.0.1_windows-x64_bin/* "${OUTPUT}/theroundtable-windows-x64/jdk"

#######################################################################
# Building the plugins
#######################################################################
bash build-plugins.sh all
cp -r "${OUTPUT}/plugins" "$SERVER_OUTPUT"

# TODO: Change this to use the plugin repo fs 
# Extracting plugin data and icons
(
  JSON_NAME="plugin-data.json"
  ICON_NAME="plugin-icon.png"
  cd "$SERVER_OUTPUT/plugins" || exit
  
  # Loop a través de todos los archivos .jar en el directorio
  for jar_file in *.jar; do
    json_path=$(unzip -l "$jar_file" | grep "$JSON_NAME" | awk '{print $4}')
    icon_path=$(unzip -l "$jar_file" | grep "$ICON_NAME" | awk '{print $4}')
    
    if [ -n "$json_path" ]; then
      unzip -p "$jar_file" "$json_path" > "$jar_file.json"
      echo "Extracted $JSON_NAME of $jar_file as $jar_file.json"
    else
      echo "The JAR $jar_file doesn't have $JSON_NAME"
    fi
    
    if [ -n "$icon_path" ]; then
          unzip -p "$jar_file" "$json_path" > "$jar_file.icon.png"
          echo "Extracted $ICON_NAME of $jar_file as $jar_file.icon.png"
    else
      echo "The JAR $jar_file doesn't have $ICON_NAME"
    fi
  done
)
