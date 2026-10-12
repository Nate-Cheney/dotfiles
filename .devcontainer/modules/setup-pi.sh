#!/bin/bash

set -euo pipefail

# non-login shell, so load nvm explicitly before using npm.
if [ -n "${NVM_DIR:-}" ] && [ -s "${NVM_DIR}/nvm.sh" ]; then
    # shellcheck disable=SC1090
    . "${NVM_DIR}/nvm.sh"
fi

echo "Using Node.js $(node --version) and npm $(npm --version)..."
echo "Installing Pi..."
npm install -g --ignore-scripts --no-audit --no-fund @earendil-works/pi-coding-agent

echo "Pi installed at $(command -v pi)"
pi --version
echo "Setup done!"

