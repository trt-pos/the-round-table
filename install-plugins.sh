#!/bin/bash
set -u

PLUGIN_NAME=$1

bash build-plugins.sh "$PLUGIN_NAME"

## This no longer works bcs the new plugin fs
# mkdir "$HOME/.round-table-dev/plugins"
# cp -r output/plugins/* ~/.round-table-dev/plugins/
# cp -r output/dev-plugins/* ~/.round-table-dev/plugins/

post_plugins() {
  PLUGIN_REPO_FOLDER=$1
  
  cd "trt-central" || exit
  bin/plugin-repo -a 127.0.0.1 -p 8500 --password abc123. --dir "$PLUGIN_REPO_FOLDER/" &
  TRT_REPO_PID=$!
  cd ..
  
  (
    cd "$PLUGIN_REPO_FOLDER" || exit
    echo "Uploading plugins from $PLUGIN_REPO_FOLDER to TRT repo..."
    for jar_file in *.jar; do
      curl -w "%{http_code}\n" \
           -X POST \
           -F "file=@${jar_file}" \
           -H "Authorization: Bearer abc123." \
           http://127.0.0.1:8500/plugin/
      curl -w "%{http_code}\n" \
           -X PUT \
           -F "file=@${jar_file}" \
           -H "Authorization: Bearer abc123." \
           http://127.0.0.1:8500/plugin/
    done
  )
  
  sleep 1
  
  kill -9 "$TRT_REPO_PID"
}

cd "output" || exit

post_plugins "plugins"
post_plugins "dev-plugins"