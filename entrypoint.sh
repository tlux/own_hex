#!/bin/sh

set -e

REGISTRY_DIR=${REGISTRY_DIR:-"/registry"}
DOCS_DIR=${DOCS_DIR:-"/docs"}
PRIVATE_KEY_PATH=${PRIVATE_KEY_PATH:-"/private_key.pem"}

if [ -n "$UID" ] && [ -n "$GID" ]; then
  chown "$UID:$GID" "$REGISTRY_DIR"
  chown "$UID:$GID" "$DOCS_DIR"
elif [ -n "$UID" ]; then
  chown "$UID" "$REGISTRY_DIR"
  chown "$UID" "$DOCS_DIR"
elif [ -n "$GID" ]; then
  chgrp "$GID" "$REGISTRY_DIR"
  chgrp "$GID" "$DOCS_DIR"
fi

if [ "$1" = "rebuild" ]; then
  mix hex.registry build "$REGISTRY_DIR" \
    --name "$REGISTRY_NAME" \
    --private-key "$PRIVATE_KEY_PATH"
  chown -R "$UID:$GID" "$REGISTRY_DIR"
  exit 0
fi

echo "Boot application"
bin/own_hex "$@"
