#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <linux | windows> "
    exit 1
fi

if [ "$1" != "linux" ] && [ "$1" != "windows" ]; then
  echo "Not supported platform: $1"
      exit 1
    
fi

# Asignar variables
DESTINO="theroundtable"
PLATFORM=$1
FILES="desktop-app/app-files-$PLATFORM"
JDK="$HOME/.jdks/openjdk-22.0.2_$PLATFORM-x64_bin/"

(
  cd desktop-app || exit
  mvn package
)

rm -rf "$DESTINO"

mkdir -p "$DESTINO"
mkdir "$DESTINO/plugins"

cp -r "desktop-app/bin" "$DESTINO"
cp -r "desktop-app/docs" "$DESTINO"
cp -r "desktop-app/styles" "$DESTINO"
cp -r "desktop-app/images" "$DESTINO"
cp -r "desktop-app/saved-images" "$DESTINO"

rm -rf "desktop-app/bin"

cp -r "$FILES/." "$DESTINO"
cp -r "$JDK" "$DESTINO/jdk"

if [ "$PLATFORM" == "linux" ]; then
  # Modifies build process to use docker. Make compatibility with old versions of glibc (Ubuntu 20.04)
    cross build --target x86_64-unknown-linux-gnu --release -p app_launcher
    cp "target/x86_64-unknown-linux-gnu/release/app_launcher" "$DESTINO/start"
fi

# Creating the .zip
zip -r -9 "$DESTINO-$PLATFORM-x64.zip" "$DESTINO"

# Deleting the previous folder
rm -rf "$DESTINO"