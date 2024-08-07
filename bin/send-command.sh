#!/bin/bash

if [[ $* ]]; then
  # On arm64, the process exe is actually box64 since it in turn wraps the bedrock_server executable
  if proc=$(find /proc -mindepth 2 -maxdepth 2 -name exe \( -lname '/data/bedrock_server-*' -o -lname /usr/local/bin/box64 \) -printf '%h' -quit); then
    if [[ $proc ]]; then
      echo "$@" > "$proc/fd/0"
    else
      echo "ERROR: unable to find bedrock server process"
      exit 2
    fi
  else
    echo "ERROR: failed to search for bedrock server process"
    exit 2
  fi
fi
