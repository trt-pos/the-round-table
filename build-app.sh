#!/bin/bash
set -u

if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <linux | windows> "
    exit 1
fi

if [ "$1" != "linux" ] && [ "$1" != "windows" ]; then
  echo "Not supported platform: $1"
      exit 1
    
fi

# Asignar variables
PLATFORM=$1
DESTINO="output/theroundtable-$PLATFORM-x64"
FILES="desktop-app/app-files-$PLATFORM"
JDK="$HOME/.jdks/openjdk-22.0.2_$PLATFORM-x64_bin/"

rm -rf "$DESTINO"

(
  cd desktop-app || exit
  mvn package
)

mkdir -p "$DESTINO"

cp -r "desktop-app/bin" "$DESTINO"
cp -r "desktop-app/docs" "$DESTINO"
cp -r "desktop-app/styles" "$DESTINO"
cp -r "desktop-app/images" "$DESTINO"

rm -rf "desktop-app/bin"

cp -r "$FILES/." "$DESTINO"
cp -r "$JDK" "$DESTINO/jdk"

if [ "$PLATFORM" == "linux" ]; then
  (
    # Modifies build process to use docker. Make compatibility with old versions of glibc (Ubuntu 20.04)
    cd "desktop-app/app-launcher" || exit
    cross build --target x86_64-unknown-linux-gnu --release -p app_launcher
    mv "target/x86_64-unknown-linux-gnu/release/app_launcher" "../../$DESTINO/start"
  )
fi