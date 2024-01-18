#!/bin/bash

# Verifica che sia stato fornito un argomento
if [ $# -eq 0 ]; then
  echo "Usage: $0 <json_file>"
  exit 1
fi

json_file=$1

# Verifica l'esistenza del file JSON
if [ ! -f "$json_file" ]; then
  echo "File not found: $json_file"
  exit 1
fi

# Parsing del file JSON
while IFS= read -r line; do
  payload_printable=$(echo "$line" | jq -r '.payload_printable')
  echo "$payload_printable"
done < "$json_file"
