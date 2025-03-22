#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "[Error] Usage: $0 <gs://bucket_name/path/to/resource>"
    exit 1
fi

gs_url="$1"

if [[ ! "$gs_url" =~ ^gs:// ]]; then
    echo "[Error] Invalid path: arg must have 'gs://' prefix"
fi

# Remove 'gs://' prefix
g_path="${gs_url#gs://}"

echo "https://console.cloud.google.com/storage/browser/$g_path"
