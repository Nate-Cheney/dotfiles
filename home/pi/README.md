# .pi

Global Pi configuration, managed via dotfiles, and stowed into `~/.pi`.

## Containerization

Pi ships without any kind of security. In order to separate Pi's execution environment from my host system, I use devcontainers. This allows me to utilize Containerization and Linux permissions to limit unwanted behavior outside of the development environment. 

This setup is **not** perfect, but has served me well thus far.

## Setup

In order to add Pi to a devcontainer, I use the following `devcontainer.json` & `setup.sh` snippets and the `pi-setup.sh` shell script.

### devcontainer.json

``` json
{
.
.
.
    "features": {
        "ghcr.io/devcontainers/features/node:2": {
            "version": "22",
            "npmVersion": "12.0.2"
        }
    },
    "mounts": [
        "source=${localEnv:HOME}/.agents,target=/home/vscode/.agents,type=bind",
        "source=${localEnv:HOME}/.pi,target=/home/vscode/.pi,type=bind"
    ],
    "postCreateCommand": "bash .devcontainer/setup.sh"
}
```

### setup.sh

``` bash
.
.
.
# Run modular setup scripts
DEVCONTAINER_DIR="$(pwd)/.devcontainer"
for file in "$DEVCONTAINER_DIR"/setup-*.sh; do
    [ -e "$file" ] || continue
    echo "Running setup file: $file..."
    bash "$file"
done
```

### setup-pi.sh

``` bash
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
```

