#!/bin/bash

set -euo pipefail

# Run modular setup scripts
DEVCONTAINER_DIR="$(pwd)/.devcontainer"
for file in "$DEVCONTAINER_DIR"/modules/setup-*.sh; do
    [ -e "$file" ] || continue
    echo "#############################################"
    echo "# Setup module: ${file##*/} "
    echo "#############################################"
    bash "$file"

    echo "Module '$file' done."
done
