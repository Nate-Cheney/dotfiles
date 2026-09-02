#!/bin/bash

set -euo pipefail

# Run modular setup scripts
DEVCONTAINER_DIR="$(pwd)/.devcontainer"
for file in "$DEVCONTAINER_DIR"/setup-*.sh; do
    [ -e "$file" ] || continue
    echo "Running setup file: $file..."
    bash "$file"
done

